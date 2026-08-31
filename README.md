# CropCheckUp

AI-assisted crop leaf disease detection in the browser.

CropCheckUp is a privacy-first React and TypeScript website. A user selects one
leaf image, then the website removes its background, prepares the model input,
runs a bundled TensorFlow Lite classifier locally, and shows the predicted crop
condition with confidence and management information. Image bytes are never
uploaded to an application API.

The product is intentionally upload-only. It does not request device capture permissions or ship native application code.

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
MobileNetV3 preprocessing inside the graph, so the website feeds 224 x 224 RGB
values in the 0-255 range and resolves outputs against
`landing/public/models/labels.txt`.

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
|-- landing/                 # React + TypeScript website
|   |-- public/models/       # TFLite, ONNX, label, and browser runtime assets
|   |-- src/components/      # Page and diagnosis workspace components
|   |-- src/services/        # Image, segmentation, classifier, and history services
|   |-- src/models/          # Diagnosis result model
|   |-- src/types/           # Shared TypeScript contracts
|   `-- tests/               # Playwright browser tests
|-- ATTRIBUTION.md           # Dataset and model-source attribution
|-- DATASET_LICENSE.md       # Derived dataset license
|-- MODEL_LICENSE.md         # Bundled model artifact licenses
|-- PRIVACY.md               # Browser privacy notes
`-- LICENSE                  # Source code license
```

## Requirements

- Node.js `>=22.12.0`.
- npm.
- A browser with WebAssembly and IndexedDB support for the diagnosis workflow.

## Website Setup

```sh
cd landing
npm ci
npm run dev
```

The website source lives in `landing/src/` and builds to a static Vite site.
React components are pre-rendered at build time for SEO and hydrated in the
browser for interactive upload, diagnosis, theme, and local-history behavior.

This repository is local-only. It intentionally has no external-site configuration or publish command.

### Validation

```sh
cd landing
npm run check
npm run build
npm run lint
npm run test:e2e
```

Playwright uses Chromium. Install its browser once when needed:

```sh
cd landing
npx playwright install chromium
```

## Browser Diagnosis Workflow

1. Select a PNG, JPEG, or WebP leaf image.
2. The ONNX background-removal model runs locally and returns a processed leaf preview.
3. Review the preview and confirm the diagnosis.
4. The TensorFlow Lite model receives a 224 x 224 RGB tensor in the 0-255 range.
5. The highest-scoring label is shown with confidence and supporting disease information.
6. The latest ten saved results can be reopened from browser-local history. Up to twenty entries are retained.

The classifier and ONNX runtime are loaded from static assets under
`landing/public/models/`. The TensorFlow Lite web client is loaded as a browser
script only when the local model initializes, which keeps the Vite prerender
Node-safe. No image upload endpoint is used.

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

The website does not require account creation and does not include analytics,
ads, or telemetry. Selected images are processed in the browser and are not
sent to an application server. Diagnosis history is stored in IndexedDB when
available, with a local-storage fallback. See [PRIVACY.md](PRIVACY.md).

## Licensing

This repository uses split licensing:

- Source code and documentation are licensed under Apache-2.0. See
  [LICENSE](LICENSE).
- The plant-disease model artifacts are licensed under `CC-BY-NC-SA-4.0`. See
  [MODEL_LICENSE.md](MODEL_LICENSE.md).
- The derived CropCheckUp dataset is licensed under `CC-BY-NC-SA-4.0`. See
  [DATASET_LICENSE.md](DATASET_LICENSE.md).
- The bundled background-removal model is distributed under its BSD-3-Clause
  notice at `landing/public/models/BACKGROUND_REMOVER_LICENSE.txt`.
- Browser runtime notices for TensorFlow Lite and ONNX Runtime Web are included
  in `landing/public/models/`.

The Apache-2.0 source code license does not grant commercial rights to the
bundled model artifacts or derived dataset.

## Citation

If you use this project or associated datasets, cite CropCheckUp using
[CITATION.cff](CITATION.cff), and also cite the original source datasets listed
in [ATTRIBUTION.md](ATTRIBUTION.md).
