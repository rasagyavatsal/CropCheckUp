# CropCheckUp

A local command-line tool that classifies crop-leaf images into 68 crop and
condition labels using a bundled Keras model. It reports predictions, confidence
scores, and disease information when available. Images are processed locally.

## Setup and usage

Use Python 3.12. Run these commands from the repository root:

```sh
python3.12 -m venv .venv-keras
. .venv-keras/bin/activate
python -m pip install -r requirements.txt
python cropcheckup.py path/to/leaf.jpg
python cropcheckup.py path/to/leaf.jpg --save-processed processed.png
```

Supports PNG, JPEG, WebP, and other Pillow-readable image formats.

- `--top-k 5`: show the five highest-scoring predictions (default: 3).
- `--json`: output results as JSON.
- `--save-processed PATH`: save the final 224×224 RGB classifier input as a
  lossless PNG for visual inspection. The source image cannot be overwritten.
- `--model-dir PATH`: load `plant_disease_model.keras`, `labels.txt`,
  `disease_info.json`, and `background_removal.onnx` from another directory
  (default: the bundled `models/`). All four files are required. Background
  removal runs locally with ONNX Runtime and does not fall back to the original
  photo if its model is missing or fails.

## Training

Place training images in `CropCheckUp-dataset/`, with one subdirectory per class,
then run `python train.py`. The script trains a MobileNetV3Large classifier and
saves the model and labels to `plant_disease_outputs/`.

To use the trained model, copy `plant_disease_model.keras` and its matching
`labels.txt` into `models/`, keeping `disease_info.json` and
`background_removal.onnx` alongside them. The CLI requires 68 labels in model
output order.

## Tests

```sh
python -m unittest discover -s tests -p 'test_*.py' -v
```

## License and attribution

Source code: [Apache-2.0](LICENSE). Bundled [model assets](MODEL_LICENSE.md) and
[dataset](DATASET_LICENSE.md): CC-BY-NC-SA-4.0 (non-commercial).
See [ATTRIBUTION.md](ATTRIBUTION.md) for dataset sources and citations.
