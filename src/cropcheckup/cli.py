#!/usr/bin/env python3
"""Command-line interface for classifying crop-leaf images."""

from __future__ import annotations

import argparse
import json
import sys
from contextlib import redirect_stdout
from pathlib import Path
from typing import Any, Sequence

from .classifier import DEFAULT_MODEL_DIR, classify


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
