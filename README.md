# CropCheckUp

AI-assisted crop leaf disease detection for mobile devices.

CropCheckUp is a Flutter app that analyzes a leaf image on-device, removes the
background, resizes the processed image for a bundled TensorFlow Lite model, and
shows the predicted crop condition with confidence and management information.
The repository also includes an Astro landing site for the public project page.

<img src="assets/logo.png" alt="CropCheckUp logo" width="140">

## Model Scope

The bundled classifier is exported as TensorFlow Lite from a MobileNetV3Large
transfer-learning pipeline. It uses 224 x 224 RGB input and supports 68 crop and
condition labels across:

Apple, Blueberry, Bottle Gourd, Cherry, Corn, Grape, Mango, Orange, Papaya,
Peach, Bell Pepper, Potato, Raspberry, Soybean, Squash, Strawberry, Tomato, and
Zucchini.

Training uses an ImageNet-pretrained MobileNetV3Large backbone, GPU-side image
augmentation, class-weighted sparse categorical cross-entropy for dataset
imbalance, and an 80/20 training/validation split. The exported model includes
MobileNetV3 preprocessing inside the graph, so the app feeds 224 x 224 RGB
values in the 0-255 range and resolves outputs against `assets/labels.txt`.

The current Kaggle training run used 59,989 images across 68 labels. The final
fine-tuned checkpoint restored the best validation-loss epoch, which reported
96.11% validation accuracy and 0.1251 validation loss before TFLite export.

CropCheckUp is an AI-assisted screening tool, not a substitute for expert
agronomy advice. Results depend on image quality, lighting, leaf visibility,
background segmentation, and whether the crop condition is represented in the
trained labels.

## Repository Layout

```text
.
|-- android/                 # Android Flutter project
|-- ios/                     # iOS Flutter project
|-- assets/                  # TFLite model, labels, disease info, logo
|-- lib/                     # Flutter app source
|   |-- models/              # Diagnosis result model
|   |-- screens/             # Home, camera, preview, and result screens
|   |-- services/            # Classifier, camera, background removal, workflow
|   `-- ui/                  # Design system, tokens, components, copy, routing
|-- test/                    # Flutter unit and widget tests
|-- landing/                 # Astro landing site
|-- ATTRIBUTION.md           # Dataset and source attribution
|-- DATASET_LICENSE.md       # Derived dataset license
|-- MODEL_LICENSE.md         # Bundled model artifact license
|-- PRIVACY.md               # App privacy notes
`-- LICENSE                  # Source code license
```

## Requirements

### Mobile App

- Flutter via FVM. This project pins Flutter `3.41.6` in `.fvmrc`.
- Dart SDK compatible with `^3.7.2`.
- Android Studio/Xcode toolchains for device or simulator builds.

### Landing Site

- Node.js `>=22.12.0`.
- npm.

## Mobile App Setup

Install the pinned Flutter version and dependencies:

```sh
fvm install
fvm flutter pub get
```

Run the app:

```sh
fvm flutter run
```

Run on a specific device:

```sh
fvm flutter devices
fvm flutter run -d <device-id>
```

## Landing Site Setup

```sh
cd landing
npm ci
npm run dev
```

The landing site source lives in `landing/src/` and builds to a static Astro
site.

## Data, Model, and Attribution

Project resources:

- Kaggle notebook: https://www.kaggle.com/code/rasagyavatsal/cropcheckup
- CropCheckUp dataset: https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset
- Source attribution: [ATTRIBUTION.md](ATTRIBUTION.md)
- Dataset license: [DATASET_LICENSE.md](DATASET_LICENSE.md)
- Model artifact license: [MODEL_LICENSE.md](MODEL_LICENSE.md)

The derived dataset uses data from PlantVillage and Mango Leaf Disease sources.
See [ATTRIBUTION.md](ATTRIBUTION.md) for original dataset links, licenses, and
citations.

## Privacy

The mobile app does not require account creation and does not include analytics,
ads, or telemetry. Camera and gallery images are processed on-device by the
bundled app pipeline and are not uploaded by this app. See [PRIVACY.md](PRIVACY.md)
for details.

## Licensing

This repository uses split licensing:

- Source code and documentation are licensed under Apache-2.0. See
  [LICENSE](LICENSE).
- Bundled model artifacts are licensed under `CC-BY-NC-SA-4.0`. See
  [MODEL_LICENSE.md](MODEL_LICENSE.md).
- The derived CropCheckUp dataset is licensed under `CC-BY-NC-SA-4.0`. See
  [DATASET_LICENSE.md](DATASET_LICENSE.md).

The Apache-2.0 source code license does not grant commercial rights to the
bundled model artifacts or derived dataset.

## Citation

If you use this project or associated datasets, cite CropCheckUp using
[CITATION.cff](CITATION.cff), and also cite the original source datasets listed
in [ATTRIBUTION.md](ATTRIBUTION.md).
