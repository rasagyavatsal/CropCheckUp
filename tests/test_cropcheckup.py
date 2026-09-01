import json
import tempfile
import unittest
from pathlib import Path

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
