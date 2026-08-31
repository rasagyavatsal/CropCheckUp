# Model Licenses

## Plant-disease classifier

The following model artifacts are bundled under `landing/public/models/`:

- `plant_disease_model.tflite`
- `labels.txt`
- `disease_info.json`

These artifacts are licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (`CC-BY-NC-SA-4.0`) license.

- **Non-Commercial**: The model artifacts are for non-commercial use only.
- **ShareAlike**: Remixes or adaptations must be distributed under the same license.
- **No commercial rights via code license**: The repository source code is Apache-2.0, but that does not grant commercial rights to these artifacts.

## Background-removal model

`background_removal.onnx` is bundled under the BSD-3-Clause license. The full
notice and copyright attribution are included in
`landing/public/models/BACKGROUND_REMOVER_LICENSE.txt`.


## Browser runtime notices

The web TFLite client and its WASM assets are generated from TensorFlow.js TFLite
web support `0.0.1-alpha.10` under Apache-2.0. ONNX Runtime Web is used under
MIT for background segmentation. The corresponding notices are shipped with
the assets in `landing/public/models/TFLITE_RUNTIME_LICENSE.txt` and
`landing/public/models/ONNXRUNTIME_LICENSE.txt`.
