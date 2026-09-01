# CropCheckUp

A small, local command-line tool for crop leaf disease screening.

CropCheckUp reads one image from the local filesystem, center-crops it to the
classifier input size, runs the bundled TensorFlow Lite model, and prints the
predicted crop condition with confidence and management information. The CLI
makes no network requests and does not write image data.

CropCheckUp is an AI-assisted screening tool, not a substitute for expert
agronomy advice. Results depend on image quality, lighting, leaf visibility,
and whether the crop condition is represented in the trained labels.

## Quick start

Requirements: Python `3.10+` and a local installation of the CLI dependencies.

```sh
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements.txt
python cropcheckup.py path/to/leaf.jpg
```

The command accepts PNG, JPEG, WebP, and other formats supported by Pillow.
The model runs on the local CPU. No server, account, or external service is
needed.

### Options

```sh
# Show the five highest-scoring labels.
python cropcheckup.py path/to/leaf.jpg --top-k 5

# Emit machine-readable output for another shell program.
python cropcheckup.py path/to/leaf.jpg --json

# Use a copy of the model assets in another directory.
python cropcheckup.py path/to/leaf.jpg --model-dir ./models
```

The JSON result contains the top prediction, confidence, raw label, crop and
condition names, supporting disease information when available, and the
remaining top-k alternatives.

## Model contract

The bundled classifier is exported as TensorFlow Lite from a MobileNetV3Large
transfer-learning pipeline. It expects a `1 x 224 x 224 x 3` `float32` input
with RGB values in the `0-255` range. `cropcheckup.py` preserves this contract
by center-cropping, resizing with bilinear interpolation, converting to RGB,
and treating fully transparent pixels as black.

The model supports 68 crop and condition labels across:

Apple, Blueberry, Bottle Gourd, Cherry, Corn, Grape, Mango, Orange, Papaya,
Peach, Bell Pepper, Potato, Raspberry, Soybean, Squash, Strawberry, Tomato,
and Zucchini.

Training uses an ImageNet-pretrained MobileNetV3Large backbone, GPU-side image
augmentation, class-weighted sparse categorical cross-entropy for dataset
imbalance, and an 80/20 training/validation split. The current Kaggle training
run used 59,989 images across 68 labels. The final fine-tuned checkpoint
restored the best validation-loss epoch, which reported 96.11% validation
accuracy and 0.1251 validation loss before TFLite export.

## Repository layout

```text
.
|-- cropcheckup.py            # The complete CLI entry point
|-- models/                   # TFLite model, labels, and disease information
|-- tests/                    # Standard-library unittest coverage
|-- ATTRIBUTION.md            # Dataset and model-source attribution
|-- DATASET_LICENSE.md        # Derived dataset license
|-- MODEL_LICENSE.md          # Bundled model license
|-- PRIVACY.md                # CLI data-handling notes
|-- requirements.txt          # Small runtime dependency set
`-- LICENSE                   # Source code license
```

## Validation

```sh
python -m unittest discover -s tests -p 'test_*.py' -v
python -m compileall -q cropcheckup.py tests
```

## Data, model, and attribution

Project resources:

- Kaggle notebook: https://www.kaggle.com/code/rasagyavatsal/cropcheckup
- CropCheckUp dataset: https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset
- Source attribution: [ATTRIBUTION.md](ATTRIBUTION.md)
- Dataset license: [DATASET_LICENSE.md](DATASET_LICENSE.md)
- Model license: [MODEL_LICENSE.md](MODEL_LICENSE.md)

The derived dataset uses data from PlantVillage and Mango Leaf Disease sources.
See [ATTRIBUTION.md](ATTRIBUTION.md) for original dataset links, licenses, and
citations.

## Privacy

The CLI processes the selected file in memory and makes no network requests.
It does not create an account, send image bytes to an API, or save diagnosis
history. See [PRIVACY.md](PRIVACY.md).

## Licensing

This repository uses split licensing:

- Source code and documentation are licensed under Apache-2.0. See
  [LICENSE](LICENSE).
- The plant-disease model artifacts are licensed under `CC-BY-NC-SA-4.0`. See
  [MODEL_LICENSE.md](MODEL_LICENSE.md).
- The derived CropCheckUp dataset is licensed under `CC-BY-NC-SA-4.0`. See
  [DATASET_LICENSE.md](DATASET_LICENSE.md).

The Apache-2.0 source code license does not grant commercial rights to the
bundled model artifacts or derived dataset.

## Citation

If you use this project or the associated datasets, cite CropCheckUp using
[CITATION.cff](CITATION.cff), and also cite the original source datasets listed
in [ATTRIBUTION.md](ATTRIBUTION.md).
