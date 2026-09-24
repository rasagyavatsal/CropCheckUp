import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from background_removal import (
    BACKGROUND_MODEL_SIZE,
    MODEL_INPUT_NAME,
    MODEL_INPUT_SHAPE,
    BackgroundRemovalError,
    BackgroundRemovalService,
    apply_background_mask,
    create_model_input,
)


class _Metadata:
    def __init__(self, name, shape, data_type):
        self.name = name
        self.shape = shape
        self.type = data_type


class _FakeSession:
    def __init__(self, output):
        self.output = output
        self.run_calls = 0

    def get_inputs(self):
        return [_Metadata(MODEL_INPUT_NAME, MODEL_INPUT_SHAPE, "tensor(float)")]

    def get_outputs(self):
        return [_Metadata("mask", [1, 1, 2, 2], "tensor(float)")]

    def run(self, output_names, inputs):
        self.run_calls += 1
        self.last_inputs = inputs
        return [self.output]


class BackgroundRemovalTests(unittest.TestCase):
    def setUp(self):
        try:
            import numpy as np
            from PIL import Image
        except ImportError as error:  # pragma: no cover - dependencies are installed in test environments
            self.skipTest(str(error))
        self.np = np
        self.Image = Image

    def test_model_input_is_normalized_nchw_float32(self):
        image = self.Image.new("RGB", (1, 1), (255, 128, 0))

        data = create_model_input(image)

        self.assertEqual(data.shape, (1, 3, BACKGROUND_MODEL_SIZE, BACKGROUND_MODEL_SIZE))
        self.assertEqual(data.dtype, self.np.float32)
        expected = self.np.asarray(
            [
                (1.0 - 0.485) / 0.229,
                (128.0 / 255.0 - 0.456) / 0.224,
                (0.0 - 0.406) / 0.225,
            ],
            dtype=self.np.float32,
        )
        self.np.testing.assert_allclose(data[0, :, 0, 0], expected, rtol=1e-6, atol=1e-6)

    def test_mask_alpha_thresholds_and_source_alpha_are_applied(self):
        opaque = self.Image.new("RGBA", (1, 1), (255, 0, 0, 255))
        transparent = self.Image.new("RGBA", (1, 1), (255, 0, 0, 0))

        fully_removed = self.np.asarray(apply_background_mask(opaque, self.np.zeros((1, 1))), dtype=self.np.uint8)
        fully_kept = self.np.asarray(apply_background_mask(opaque, self.np.ones((1, 1))), dtype=self.np.uint8)
        half_kept = self.np.asarray(apply_background_mask(opaque, self.np.full((1, 1), 0.5)), dtype=self.np.uint8)
        existing_alpha = self.np.asarray(apply_background_mask(transparent, self.np.ones((1, 1))), dtype=self.np.uint8)

        self.assertEqual(int(fully_removed[0, 0, 3]), 0)
        self.assertEqual(int(fully_kept[0, 0, 3]), 255)
        self.assertEqual(int(half_kept[0, 0, 3]), 128)
        self.assertEqual(int(existing_alpha[0, 0, 3]), 0)

    def test_session_is_lazy_and_reused(self):
        session = _FakeSession(self.np.ones((1, 1, 2, 2), dtype=self.np.float32))
        factory_calls = []

        with tempfile.NamedTemporaryFile(suffix=".onnx") as model_file:
            service = BackgroundRemovalService(
                Path(model_file.name),
                session_factory=lambda path: factory_calls.append(path) or session,
            )
            self.assertEqual(factory_calls, [])

            image = self.Image.new("RGB", (4, 3), (20, 40, 60))
            first = service.remove_background(image)
            second = service.remove_background(image)

        self.assertEqual(len(factory_calls), 1)
        self.assertEqual(session.run_calls, 2)
        self.assertEqual(first.mode, "RGBA")
        self.assertEqual(first.size, image.size)
        self.assertEqual(second.size, image.size)
        self.assertEqual(session.last_inputs[MODEL_INPUT_NAME].shape, (1, 3, 320, 320))

    def test_invalid_mask_output_fails_clearly(self):
        session = _FakeSession(self.np.ones((1, 2, 2, 2), dtype=self.np.float32))

        with tempfile.NamedTemporaryFile(suffix=".onnx") as model_file:
            service = BackgroundRemovalService(Path(model_file.name), session_factory=lambda path: session)
            with self.assertRaisesRegex(BackgroundRemovalError, "mask has shape"):
                service.remove_background(self.Image.new("RGB", (2, 2), (20, 40, 60)))

    def test_non_numeric_mask_output_fails_clearly(self):
        with tempfile.NamedTemporaryFile(suffix=".onnx") as model_file:
            cases = (
                (self.np.array([["invalid"]], dtype=object), "mask output has type object"),
                ([[1.0], [1.0, 2.0]], "mask output is invalid"),
            )
            for output, expected_error in cases:
                with self.subTest(expected_error=expected_error):
                    service = BackgroundRemovalService(
                        Path(model_file.name), session_factory=lambda path: _FakeSession(output)
                    )
                    with self.assertRaisesRegex(BackgroundRemovalError, expected_error):
                        service.remove_background(self.Image.new("RGB", (2, 2), (20, 40, 60)))

    def test_invalid_output_metadata_fails_before_inference(self):
        class InvalidOutputSession(_FakeSession):
            def get_outputs(self):
                return [_Metadata("mask", [1, 1, 2, 2], "tensor(int64)")]

        session = InvalidOutputSession(self.np.ones((1, 1, 2, 2), dtype=self.np.float32))
        with tempfile.NamedTemporaryFile(suffix=".onnx") as model_file:
            service = BackgroundRemovalService(Path(model_file.name), session_factory=lambda path: session)
            with self.assertRaisesRegex(BackgroundRemovalError, "mask output type"):
                service.remove_background(self.Image.new("RGB", (2, 2), (20, 40, 60)))
        self.assertEqual(session.run_calls, 0)

    def test_inference_failure_fails_clearly(self):
        class FailingSession(_FakeSession):
            def run(self, output_names, inputs):
                raise RuntimeError("inference device failed")

        with tempfile.NamedTemporaryFile(suffix=".onnx") as model_file:
            service = BackgroundRemovalService(
                Path(model_file.name), session_factory=lambda path: FailingSession(None)
            )
            with self.assertRaisesRegex(BackgroundRemovalError, "background-removal inference failed: inference device failed"):
                service.remove_background(self.Image.new("RGB", (2, 2), (20, 40, 60)))

    def test_missing_runtime_and_corrupt_asset_have_actionable_errors(self):
        with tempfile.NamedTemporaryFile(suffix=".onnx") as model_file:
            model_path = Path(model_file.name)
            model_file.write(b"not an ONNX model")
            model_file.flush()

            with patch.dict("sys.modules", {"onnxruntime": None}):
                with self.assertRaisesRegex(RuntimeError, "ONNX Runtime is required.*pip install -r requirements.txt"):
                    BackgroundRemovalService(model_path).initialize()

            with self.assertRaisesRegex(BackgroundRemovalError, "could not load background-removal model") as error:
                BackgroundRemovalService(model_path).initialize()
            self.assertIn(str(model_path), str(error.exception))


if __name__ == "__main__":
    unittest.main()
