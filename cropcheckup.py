#!/usr/bin/env python3
"""Classify a crop-leaf image with the bundled CropCheckUp TFLite model."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any, Sequence

INPUT_SIZE = 224
EXPECTED_LABEL_COUNT = 68
DEFAULT_MODEL_DIR = Path(__file__).resolve().parent / "models"


def humanize(value: str) -> str:
    """Convert a model label segment into a readable name."""
    return " ".join(value.replace("_", " ").split())


def label_parts(raw_label: str) -> tuple[str, str]:
    """Return the crop and condition names encoded in a model label."""
    crop, separator, condition = raw_label.partition("___")
    if not separator:
        return humanize(crop), "Unknown"
    condition_name = "Healthy" if condition.lower() == "healthy" else humanize(condition)
    return humanize(crop), condition_name


def positive_integer(value: str) -> int:
    number = int(value)
    if number < 1:
        raise argparse.ArgumentTypeError("must be at least 1")
    return number


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="cropcheckup",
        description="Classify one crop-leaf image locally with CropCheckUp.",
    )
    parser.add_argument("image", type=Path, help="path to a PNG, JPEG, WebP, or other Pillow-readable image")
    parser.add_argument(
        "--model-dir",
        type=Path,
        default=DEFAULT_MODEL_DIR,
        help="directory containing plant_disease_model.tflite, labels.txt, and disease_info.json",
    )
    parser.add_argument(
        "--top-k",
        type=positive_integer,
        default=3,
        help="number of predictions to show (default: 3)",
    )
    parser.add_argument("--json", action="store_true", help="write the result as JSON")
    return parser


def load_labels(path: Path) -> list[str]:
    labels = [line.strip() for line in path.read_text(encoding="utf-8").splitlines() if line.strip()]
    if len(labels) != EXPECTED_LABEL_COUNT:
        raise ValueError(f"{path} contains {len(labels)} labels; expected {EXPECTED_LABEL_COUNT}")
    return labels


def load_disease_info(path: Path) -> dict[str, dict[str, Any]]:
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError(f"{path} must contain a JSON object")
    return {key: item for key, item in value.items() if isinstance(key, str) and isinstance(item, dict)}


def prepare_image(path: Path):
    """Center-crop and resize an image to the model's 224 x 224 RGB contract."""
    try:
        import numpy as np
        from PIL import Image, ImageOps
    except ImportError as error:
        raise RuntimeError("install the CLI dependencies with: python -m pip install -r requirements.txt") from error

    with Image.open(path) as image:
        oriented = ImageOps.exif_transpose(image.convert("RGBA"))
        rgba = ImageOps.fit(
            oriented,
            (INPUT_SIZE, INPUT_SIZE),
            method=Image.Resampling.BILINEAR,
            centering=(0.5, 0.5),
        )
        pixels = np.asarray(rgba, dtype=np.uint8)

    rgb = pixels[:, :, :3].copy()
    rgb[pixels[:, :, 3] == 0] = 0
    return np.expand_dims(rgb.astype(np.float32), axis=0)


def make_prediction(raw_label: str, confidence: float, info: dict[str, Any] | None = None) -> dict[str, Any]:
    crop, condition = label_parts(raw_label)
    prediction: dict[str, Any] = {
        "label": raw_label,
        "crop": crop,
        "condition": condition,
        "confidence": round(float(confidence), 6),
    }
    if info:
        for key in ("symptoms", "causes", "management"):
            if isinstance(info.get(key), str) and info[key].strip():
                prediction[key] = info[key]
    return prediction


def classify(image_path: Path, model_dir: Path, top_k: int) -> dict[str, Any]:
    try:
        import numpy as np
        from ai_edge_litert.interpreter import Interpreter
    except ImportError as error:
        raise RuntimeError("install the CLI dependencies with: python -m pip install -r requirements.txt") from error

    model_path = model_dir / "plant_disease_model.tflite"
    labels_path = model_dir / "labels.txt"
    info_path = model_dir / "disease_info.json"
    for resource in (model_path, labels_path, info_path):
        if not resource.is_file():
            raise FileNotFoundError(f"required model resource not found: {resource}")

    labels = load_labels(labels_path)
    disease_info = load_disease_info(info_path)
    input_data = prepare_image(image_path)
    interpreter = Interpreter(model_path=str(model_path))

    try:
        interpreter.allocate_tensors()
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        if len(input_details) != 1 or len(output_details) != 1:
            raise ValueError("the classifier must expose one input tensor and one output tensor")

        input_detail = input_details[0]
        expected_shape = (1, INPUT_SIZE, INPUT_SIZE, 3)
        actual_shape = tuple(int(value) for value in input_detail["shape"])
        if actual_shape != expected_shape:
            raise ValueError(f"the classifier input shape is {actual_shape}; expected {expected_shape}")
        if np.dtype(input_detail["dtype"]) != np.dtype(np.float32):
            raise ValueError(f"the classifier input type is {input_detail['dtype']}; expected float32")

        interpreter.set_tensor(input_detail["index"], input_data)
        interpreter.invoke()
        scores = np.asarray(interpreter.get_tensor(output_details[0]["index"]), dtype=np.float32).reshape(-1)
        if len(scores) != len(labels):
            raise ValueError(f"the classifier returned {len(scores)} scores; expected {len(labels)}")
        if not np.isfinite(scores).all():
            raise ValueError("the classifier returned a non-finite score")

        indices = np.argsort(scores)[::-1][: min(top_k, len(labels))]
        predictions = [make_prediction(labels[int(index)], float(scores[index]), disease_info.get(labels[int(index)])) for index in indices]
        return {
            "image": str(image_path),
            "prediction": predictions[0],
            "alternatives": predictions[1:],
        }
    finally:
        close = getattr(interpreter, "close", None)
        if callable(close):
            close()


def print_result(result: dict[str, Any]) -> None:
    prediction = result["prediction"]
    print(f"Prediction: {prediction['crop']} — {prediction['condition']}")
    print(f"Confidence: {prediction['confidence'] * 100:.1f}%")
    print(f"Label: {prediction['label']}")
    for key, title in (("symptoms", "Symptoms"), ("causes", "Causes"), ("management", "Management")):
        if key in prediction:
            print(f"{title}: {prediction[key]}")

    alternatives = result["alternatives"]
    if alternatives:
        print("\nAlternatives:")
        for item in alternatives:
            print(f"- {item['crop']} — {item['condition']} ({item['confidence'] * 100:.1f}%)")


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    if not args.image.is_file():
        print(f"error: image not found: {args.image}", file=sys.stderr)
        return 2

    try:
        result = classify(args.image, args.model_dir, args.top_k)
    except (OSError, RuntimeError, ValueError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print_result(result)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
