import io
import json
import tempfile
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from types import ModuleType, SimpleNamespace
from unittest.mock import Mock, patch

from background_removal import BackgroundRemovalError, apply_background_mask
from cropcheckup import (
    DEFAULT_MODEL_DIR,
    classify,
    label_parts,
    load_labels,
    main,
    prepare_image,
)


class CropCheckUpTests(unittest.TestCase):
    def _write_stub_model_assets(self, model_dir):
        model_dir.mkdir()
        (model_dir / "plant_disease_model.keras").write_bytes(b"stub classifier")
        (model_dir / "labels.txt").write_bytes((DEFAULT_MODEL_DIR / "labels.txt").read_bytes())
        (model_dir / "disease_info.json").write_text("{}", encoding="utf-8")
        (model_dir / "background_removal.onnx").write_bytes(b"stub segmentation model")

    def test_label_parts_humanizes_crop_and_condition(self):
        self.assertEqual(label_parts("Cherry_(including_sour)___healthy"), ("Cherry (including sour)", "Healthy"))
        self.assertEqual(label_parts("Tomato___Late_blight"), ("Tomato", "Late blight"))
        self.assertEqual(label_parts("Unknown"), ("Unknown", "Unknown"))

    def test_bundled_labels_have_expected_count(self):
        labels = load_labels(DEFAULT_MODEL_DIR / "labels.txt")
        self.assertEqual(len(labels), 68)
        self.assertEqual(labels[0], "Apple___Apple_scab")

    def test_prepare_image_returns_rgb_float32_model_input(self):
        try:
            import numpy as np
            from PIL import Image
        except ImportError as error:  # pragma: no cover - dependencies are installed in test environments
            self.skipTest(str(error))

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "transparent.png"
            Image.new("RGBA", (320, 180), (255, 20, 20, 0)).save(path)
            data = prepare_image(path)

        self.assertEqual(data.shape, (1, 224, 224, 3))
        self.assertEqual(data.dtype, np.float32)
        self.assertTrue(np.all(data == 0))

    def test_prepare_image_composites_partial_alpha_on_black(self):
        import numpy as np
        from PIL import Image

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "alpha.png"
            image = Image.new("RGBA", (3, 1))
            image.putdata([(255, 0, 0, 255), (255, 0, 0, 128), (255, 0, 0, 0)])
            image.save(path)
            data = prepare_image(path)

        self.assertEqual(data.shape, (1, 224, 224, 3))
        self.assertEqual(data.dtype, np.float32)
        np.testing.assert_array_equal(data[0, 112, 0], [255, 0, 0])
        np.testing.assert_allclose(data[0, 112, 112], [128, 0, 0], atol=1)
        np.testing.assert_array_equal(data[0, 112, -1], [0, 0, 0])

    def test_prepare_image_applies_mask_before_black_composite(self):
        import numpy as np
        from PIL import Image

        seen = []

        def mask_image(image, model_path):
            seen.append((image.mode, image.getpixel((0, 0)), model_path))
            return apply_background_mask(image, np.full((1, 1), 0.5, dtype=np.float32))

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "partial.png"
            model_path = Path(directory) / "background_removal.onnx"
            Image.new("RGBA", (1, 1), (255, 0, 0, 128)).save(path)
            with patch("background_removal.remove_background", side_effect=mask_image):
                data = prepare_image(path, model_path)

        self.assertEqual(seen, [("RGBA", (255, 0, 0, 128), model_path)])
        np.testing.assert_array_equal(data[0, 112, 112], [64, 0, 0])

    def test_prepare_image_resizes_full_rectangular_image(self):
        import numpy as np
        from PIL import Image, ImageDraw

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "wide.png"
            image = Image.new("RGB", (448, 224), (0, 255, 0))
            draw = ImageDraw.Draw(image)
            draw.rectangle((0, 0, 63, 223), fill=(255, 0, 0))
            draw.rectangle((384, 0, 447, 223), fill=(0, 0, 255))
            image.save(path)
            data = prepare_image(path)

        np.testing.assert_array_equal(data[0, 112, 0], [255, 0, 0])
        np.testing.assert_array_equal(data[0, 112, 112], [0, 255, 0])
        np.testing.assert_array_equal(data[0, 112, -1], [0, 0, 255])

    def test_prepare_image_corrects_exif_before_background_removal(self):
        import numpy as np
        from PIL import Image

        seen = []

        def capture_image(image, model_path):
            seen.append((image.size, image.getpixel((0, 0)), image.getpixel((0, 3))))
            return image

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "oriented.png"
            image = Image.new("RGB", (4, 2), (255, 0, 0))
            for y in range(2):
                for x in (2, 3):
                    image.putpixel((x, y), (0, 0, 255))
            exif = Image.Exif()
            exif[274] = 6
            image.save(path, exif=exif)
            with patch("background_removal.remove_background", side_effect=capture_image):
                data = prepare_image(path, Path(directory) / "background_removal.onnx")

        self.assertEqual(seen, [((2, 4), (255, 0, 0, 255), (0, 0, 255, 255))])
        np.testing.assert_array_equal(data[0, 0, 112], [255, 0, 0])
        np.testing.assert_array_equal(data[0, -1, 112], [0, 0, 255])

    def test_saved_processed_png_matches_classifier_input(self):
        import numpy as np
        from PIL import Image

        with tempfile.TemporaryDirectory() as directory:
            source_path = Path(directory) / "source.png"
            output_path = Path(directory) / "processed.png"
            model_path = Path(directory) / "background_removal.onnx"
            source = Image.new("RGBA", (3, 1))
            source.putdata([(255, 0, 0, 255), (0, 255, 0, 128), (0, 0, 255, 0)])
            source.save(source_path)
            original_bytes = source_path.read_bytes()

            def mask_image(image, model_path):
                return apply_background_mask(image, np.full((1, 1), 0.5, dtype=np.float32))

            with patch("background_removal.remove_background", side_effect=mask_image):
                data = prepare_image(source_path, model_path, output_path)

            with Image.open(output_path) as saved:
                self.assertEqual(saved.format, "PNG")
                self.assertEqual(saved.mode, "RGB")
                self.assertEqual(saved.size, (224, 224))
                np.testing.assert_array_equal(np.asarray(saved, dtype=np.float32), data[0])
            self.assertEqual(source_path.read_bytes(), original_bytes)

    def test_save_processed_rejects_source_aliases(self):
        from PIL import Image

        with tempfile.TemporaryDirectory() as directory:
            source_path = Path(directory) / "source.png"
            Image.new("RGB", (2, 2), (255, 0, 0)).save(source_path)
            original_bytes = source_path.read_bytes()
            symlink_path = Path(directory) / "symlink.png"
            symlink_path.symlink_to(source_path)
            hardlink_path = Path(directory) / "hardlink.png"
            hardlink_path.hardlink_to(source_path)

            for output_path in (source_path, symlink_path, hardlink_path):
                with self.subTest(output_path=output_path):
                    with self.assertRaisesRegex(ValueError, "must not overwrite the source image"):
                        prepare_image(source_path, save_processed=output_path)
                    self.assertEqual(source_path.read_bytes(), original_bytes)

    def test_save_processed_reports_write_failure(self):
        from PIL import Image

        with tempfile.TemporaryDirectory() as directory:
            source_path = Path(directory) / "source.png"
            output_path = Path(directory) / "missing" / "processed.png"
            Image.new("RGB", (2, 2), (255, 0, 0)).save(source_path)

            with self.assertRaisesRegex(OSError, "could not save processed image to"):
                prepare_image(source_path, save_processed=output_path)

    def test_cli_preserves_text_and_json_output_with_diagnostics_on_stderr(self):
        from PIL import Image

        with tempfile.TemporaryDirectory() as directory:
            source_path = Path(directory) / "source.png"
            output_path = Path(directory) / "processed.png"
            Image.new("RGB", (2, 2), (255, 0, 0)).save(source_path)
            result = {
                "image": str(source_path),
                "prediction": {
                    "label": "Apple___Black_rot",
                    "crop": "Apple",
                    "condition": "Black rot",
                    "confidence": 0.625,
                    "symptoms": "Dark spots",
                },
                "alternatives": [{
                    "label": "Apple___healthy",
                    "crop": "Apple",
                    "condition": "Healthy",
                    "confidence": 0.25,
                }],
            }

            def noisy_classify(*args, **kwargs):
                print("model initialized")
                return result

            cases = (
                (("--top-k", "2", "--json", "--save-processed", str(output_path)), 2, output_path),
                ((), 3, None),
            )
            for flags, expected_top_k, expected_output in cases:
                with self.subTest(flags=flags):
                    stdout = io.StringIO()
                    stderr = io.StringIO()
                    with patch("cropcheckup.classify", side_effect=noisy_classify) as classify_mock:
                        with redirect_stdout(stdout), redirect_stderr(stderr):
                            exit_status = main([str(source_path), *flags])

                    self.assertEqual(exit_status, 0)
                    classify_mock.assert_called_once_with(
                        source_path,
                        DEFAULT_MODEL_DIR,
                        expected_top_k,
                        save_processed=expected_output,
                    )
                    self.assertEqual(stderr.getvalue(), "model initialized\n")
                    if flags:
                        self.assertEqual(json.loads(stdout.getvalue()), result)
                    else:
                        self.assertEqual(
                            stdout.getvalue(),
                            "Prediction: Apple — Black rot\n"
                            "Confidence: 62.5%\n"
                            "Label: Apple___Black_rot\n"
                            "Symptoms: Dark spots\n"
                            "\nAlternatives:\n"
                            "- Apple — Healthy (25.0%)\n",
                        )

    def test_classify_keeps_positional_arguments_and_prediction_fields(self):
        import numpy as np

        class FakeClassifier:
            inputs = [SimpleNamespace(shape=(None, 224, 224, 3), dtype=np.float32)]
            outputs = [object()]

            def __call__(self, input_data, training=False):
                scores = np.zeros((1, 68), dtype=np.float32)
                scores[0, 1] = 0.625
                scores[0, 2] = 0.25
                scores[0, 0] = 0.125
                return scores

        with tempfile.TemporaryDirectory() as directory:
            model_dir = Path(directory) / "custom-models"
            self._write_stub_model_assets(model_dir)
            (model_dir / "disease_info.json").write_text(
                json.dumps({"Apple___Black_rot": {"symptoms": "Dark spots", "management": "Remove leaves"}}),
                encoding="utf-8",
            )
            image_path = Path(directory) / "leaf.png"
            output_path = Path(directory) / "processed.png"
            load_model = Mock(return_value=FakeClassifier())
            tensorflow_stub = ModuleType("tensorflow")
            tensorflow_stub.keras = SimpleNamespace(models=SimpleNamespace(load_model=load_model))

            with patch.dict("sys.modules", {"tensorflow": tensorflow_stub}):
                with patch("cropcheckup.prepare_image", return_value=np.zeros((1, 224, 224, 3), dtype=np.float32)) as prepare:
                    result = classify(image_path, model_dir, 2)
                    result_with_output = classify(image_path, model_dir, 1, save_processed=output_path)

            self.assertEqual(prepare.call_count, 2)
            prepare.assert_any_call(image_path, model_dir / "background_removal.onnx", None)
            prepare.assert_any_call(image_path, model_dir / "background_removal.onnx", output_path)
            self.assertEqual(load_model.call_count, 2)
            self.assertEqual(result, {
                "image": str(image_path),
                "prediction": {
                    "label": "Apple___Black_rot",
                    "crop": "Apple",
                    "condition": "Black rot",
                    "confidence": 0.625,
                    "symptoms": "Dark spots",
                    "management": "Remove leaves",
                },
                "alternatives": [{
                    "label": "Apple___Cedar_apple_rust",
                    "crop": "Apple",
                    "condition": "Cedar apple rust",
                    "confidence": 0.25,
                }],
            })
            self.assertEqual(result_with_output["prediction"], result["prediction"])
            self.assertEqual(result_with_output["alternatives"], [])

    def test_missing_background_asset_fails_without_json_output(self):
        from PIL import Image

        with tempfile.TemporaryDirectory() as directory:
            model_dir = Path(directory) / "custom-models"
            self._write_stub_model_assets(model_dir)
            (model_dir / "background_removal.onnx").unlink()
            image_path = Path(directory) / "leaf.png"
            Image.new("RGB", (2, 2), (30, 80, 40)).save(image_path)
            stdout = io.StringIO()
            stderr = io.StringIO()

            with redirect_stdout(stdout), redirect_stderr(stderr):
                status = main([str(image_path), "--model-dir", str(model_dir), "--json"])

            self.assertEqual(status, 1)
            self.assertEqual(stdout.getvalue(), "")
            self.assertIn(str(model_dir / "background_removal.onnx"), stderr.getvalue())
            self.assertIn("--model-dir", stderr.getvalue())

    def test_inference_and_save_failures_stop_before_classification(self):
        from PIL import Image

        with tempfile.TemporaryDirectory() as directory:
            model_dir = Path(directory) / "custom-models"
            self._write_stub_model_assets(model_dir)
            image_path = Path(directory) / "leaf.png"
            Image.new("RGB", (2, 2), (30, 80, 40)).save(image_path)
            load_model = Mock()
            tensorflow_stub = ModuleType("tensorflow")
            tensorflow_stub.keras = SimpleNamespace(models=SimpleNamespace(load_model=load_model))

            cases = (
                (BackgroundRemovalError("background-removal inference failed: device error"), None, "inference failed"),
                (None, Path(directory) / "missing" / "processed.png", "could not save processed image"),
            )
            for failure, output_path, expected_error in cases:
                with self.subTest(expected_error=expected_error):
                    stdout = io.StringIO()
                    stderr = io.StringIO()
                    with patch.dict("sys.modules", {"tensorflow": tensorflow_stub}):
                        with patch("background_removal.remove_background", side_effect=failure or (lambda image, path: image)):
                            arguments = [str(image_path), "--model-dir", str(model_dir), "--json"]
                            if output_path is not None:
                                arguments.extend(("--save-processed", str(output_path)))
                            with redirect_stdout(stdout), redirect_stderr(stderr):
                                status = main(arguments)

                    self.assertEqual(status, 1)
                    self.assertEqual(stdout.getvalue(), "")
                    self.assertIn(expected_error, stderr.getvalue())
                    load_model.assert_not_called()

    def test_bundled_model_produces_prediction(self):
        try:
            import numpy as np
            from PIL import Image, ImageDraw
        except ImportError as error:  # pragma: no cover - dependencies are installed in test environments
            self.skipTest(str(error))

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "leaf.png"
            output_path = Path(directory) / "processed.png"
            image = Image.new("RGB", (320, 240), (235, 240, 220))
            draw = ImageDraw.Draw(image)
            draw.ellipse((80, 20, 260, 220), fill=(40, 145, 60))
            draw.line((170, 40, 170, 205), fill=(220, 220, 120), width=6)
            image.save(path)
            result = classify(path, DEFAULT_MODEL_DIR, top_k=2, save_processed=output_path)
            with Image.open(output_path) as saved:
                self.assertEqual(saved.format, "PNG")
                self.assertEqual(saved.mode, "RGB")
                self.assertEqual(saved.size, (224, 224))

        self.assertIn("prediction", result)
        self.assertIn(result["prediction"]["label"], load_labels(DEFAULT_MODEL_DIR / "labels.txt"))
        self.assertGreaterEqual(result["prediction"]["confidence"], 0)
        self.assertLessEqual(result["prediction"]["confidence"], 1)
        self.assertEqual(len(result["alternatives"]), 1)
        self.assertTrue(json.dumps(result))


if __name__ == "__main__":
    unittest.main()
