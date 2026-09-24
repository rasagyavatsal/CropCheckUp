import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from background_removal import apply_background_mask
from cropcheckup import (
    DEFAULT_MODEL_DIR,
    classify,
    label_parts,
    load_labels,
    prepare_image,
)


class CropCheckUpTests(unittest.TestCase):
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

    def test_bundled_model_produces_prediction(self):
        try:
            import numpy as np
            from PIL import Image, ImageDraw
        except ImportError as error:  # pragma: no cover - dependencies are installed in test environments
            self.skipTest(str(error))

        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "leaf.png"
            image = Image.new("RGB", (320, 240), (235, 240, 220))
            draw = ImageDraw.Draw(image)
            draw.ellipse((80, 20, 260, 220), fill=(40, 145, 60))
            draw.line((170, 40, 170, 205), fill=(220, 220, 120), width=6)
            image.save(path)
            result = classify(path, DEFAULT_MODEL_DIR, top_k=2)

        self.assertIn("prediction", result)
        self.assertIn(result["prediction"]["label"], load_labels(DEFAULT_MODEL_DIR / "labels.txt"))
        self.assertGreaterEqual(result["prediction"]["confidence"], 0)
        self.assertLessEqual(result["prediction"]["confidence"], 1)
        self.assertEqual(len(result["alternatives"]), 1)
        self.assertTrue(json.dumps(result))


if __name__ == "__main__":
    unittest.main()
