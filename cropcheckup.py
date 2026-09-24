#!/usr/bin/env python3
"""Classify a crop-leaf image with the CropCheckUp Keras model."""

from __future__ import annotations

import argparse
import json
import sys
from contextlib import redirect_stdout
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
        help="directory containing the classifier assets and background_removal.onnx",
    )
    parser.add_argument(
        "--top-k",
        type=positive_integer,
        default=3,
        help="number of predictions to show (default: 3)",
    )
    parser.add_argument(
        "--save-processed",
        type=Path,
        metavar="PATH",
        help="save the final 224×224 RGB classifier input as a PNG",
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


def prepare_image(
    path: Path,
    background_model_path: Path | None = None,
    save_processed: Path | None = None,
):
    """Orient, optionally segment, composite, and resize for the classifier."""
    if save_processed is not None:
        save_processed = Path(save_processed)
        if save_processed.resolve() == path.resolve() or (
            save_processed.exists() and save_processed.samefile(path)
        ):
            raise ValueError(f"processed image output must not overwrite the source image: {path}")

    try:
        import numpy as np
        from PIL import Image, ImageOps
    except ImportError as error:
        raise RuntimeError("install the CLI dependencies with: python -m pip install -r requirements.txt") from error

    with Image.open(path) as image:
        oriented = ImageOps.exif_transpose(image).convert("RGBA")
        if background_model_path is not None:
            from background_removal import remove_background

            oriented = remove_background(oriented, background_model_path)
        # Composite before resizing so hidden RGB does not bleed into leaf edges.
        black = Image.new("RGBA", oriented.size, (0, 0, 0, 255))
        rgb = Image.alpha_composite(black, oriented).convert("RGB")
        resized = rgb.resize((INPUT_SIZE, INPUT_SIZE), resample=Image.Resampling.BILINEAR)
        if save_processed is not None:
            try:
                resized.save(save_processed, format="PNG")
            except (OSError, ValueError) as error:
                raise OSError(f"could not save processed image to {save_processed}: {error}") from error
        return np.expand_dims(np.asarray(resized, dtype=np.float32), axis=0)


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


def classify(
    image_path: Path,
    model_dir: Path,
    top_k: int,
    save_processed: Path | None = None,
) -> dict[str, Any]:
    model_dir = Path(model_dir)
    if not model_dir.is_dir():
        raise FileNotFoundError(f"model directory not found: {model_dir}; choose a directory with --model-dir")
    model_path = model_dir / "plant_disease_model.keras"
    labels_path = model_dir / "labels.txt"
    info_path = model_dir / "disease_info.json"
    background_model_path = model_dir / "background_removal.onnx"
    for resource in (model_path, labels_path, info_path, background_model_path):
        if not resource.is_file():
            raise FileNotFoundError(
                f"required model resource not found: {resource}; "
                "add it to --model-dir or select a directory with all four model assets"
            )

    try:
        import numpy as np
        from tensorflow import keras
    except ImportError as error:
        raise RuntimeError("install the CLI dependencies with: python -m pip install -r requirements.txt") from error

    labels = load_labels(labels_path)
    disease_info = load_disease_info(info_path)
    input_data = prepare_image(image_path, background_model_path, save_processed)
    model = keras.models.load_model(model_path, compile=False)
    if len(model.inputs) != 1 or len(model.outputs) != 1:
        raise ValueError("the classifier must expose one input tensor and one output tensor")
    input_tensor = model.inputs[0]
    actual_shape = tuple(input_tensor.shape)
    if actual_shape not in ((None, INPUT_SIZE, INPUT_SIZE, 3), (1, INPUT_SIZE, INPUT_SIZE, 3)):
        raise ValueError(f"the classifier input shape is {actual_shape}; expected (None or 1, 224, 224, 3)")
    if np.dtype(input_tensor.dtype) != np.dtype(np.float32):
        raise ValueError(f"the classifier input type is {input_tensor.dtype}; expected float32")

    scores = np.asarray(model(input_data, training=False), dtype=np.float32)
    if scores.shape != (1, len(labels)):
        raise ValueError(f"the classifier output shape is {scores.shape}; expected (1, {len(labels)})")
    scores = scores[0]
    if not np.isfinite(scores).all():
        raise ValueError("the classifier returned a non-finite score")

    indices = np.argsort(scores)[::-1][: min(top_k, len(labels))]
    predictions = [make_prediction(labels[int(index)], float(scores[index]), disease_info.get(labels[int(index)])) for index in indices]
    return {
        "image": str(image_path),
        "prediction": predictions[0],
        "alternatives": predictions[1:],
    }


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
        # Keep library diagnostics off stdout so --json emits one JSON document.
        with redirect_stdout(sys.stderr):
            result = classify(
                args.image,
                args.model_dir,
                args.top_k,
                save_processed=args.save_processed,
            )
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
