# CropCheckUp

A local command-line tool that classifies crop-leaf images into 68 crop and
condition labels using a bundled Keras model. It reports predictions, confidence
scores, and disease information when available. Images are processed locally.

## Setup

Use Python 3.12. From the repository root, create an environment and install
the dependencies:

```sh
python3.12 -m venv .venv-keras
. .venv-keras/bin/activate
python -m pip install -r requirements.txt
```

The requirements include TensorFlow for the Keras classifier, ONNX Runtime for
background removal, NumPy, and Pillow. The bundled models run locally; inference
does not need a network connection. Background removal adds CPU work and memory
use. The ONNX file itself is about 4.6 MB. Its input is 320×320, but the mask
is applied at the source image's full resolution, with no 1024-pixel limit.

## Classify an image

```sh
python cropcheckup.py leaf.jpg
python cropcheckup.py leaf.jpg --save-processed processed.png
python cropcheckup.py leaf.jpg --json
```

The CLI accepts PNG, JPEG, WebP, and other Pillow-readable formats. By default,
it corrects EXIF orientation, removes the background with the bundled ONNX
model, preserves existing transparency, and composites the result onto black.
It then resizes the entire image to 224×224 with bilinear interpolation and
passes float32 RGB values in `[0, 255]` to the Keras classifier. Rectangular
images are resized without cropping or padding. If background removal fails,
classification stops with an error instead of using the original photo.

- `--top-k 5`: show the five highest-scoring predictions (default: 3).
- `--json`: output results as JSON; diagnostics go to stderr.
- `--save-processed PATH`: save the final 224×224 RGB classifier input as a
  lossless PNG for visual inspection. The source image is left intact and cannot
  be used as the output path.
- `--model-dir PATH`: load `plant_disease_model.keras`, `labels.txt`,
  `disease_info.json`, and `background_removal.onnx` from another directory
  (default: the bundled `models/`). All four files are required.

## Background-removal model

The bundled [`background_removal.onnx`](models/background_removal.onnx) was
recovered from the [historical CropCheckUp browser implementation](https://github.com/rasagyavatsal/CropCheckUp/tree/b8036567f6af4208d61202167a3022549ebfdc75).
It was previously used for app input images. The model used to prepare the
training dataset has not been identified, so we cannot establish that it was
the same model. The ONNX asset is BSD 3-Clause licensed; its [full notice](models/BACKGROUND_REMOVER_LICENSE.txt)
and further [attribution](ATTRIBUTION.md) are included in this repository.

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

Source code: [Apache-2.0](LICENSE). The bundled classifier assets are
[CC-BY-NC-SA-4.0](MODEL_LICENSE.md) (non-commercial); the background-removal
model is [BSD 3-Clause](models/BACKGROUND_REMOVER_LICENSE.txt). See
[DATASET_LICENSE.md](DATASET_LICENSE.md) and [ATTRIBUTION.md](ATTRIBUTION.md)
for dataset terms, sources, and citations.
