# Model License

## Plant disease classifier

The following classifier and supporting information files are bundled under
`models/`:

- `plant_disease_model.keras`
- `plant_disease_model.h5`
- `plant_disease_model.tflite`
- `labels.txt`
- `disease_info.json`

These model and supporting information artifacts are licensed under the
Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
(`CC-BY-NC-SA-4.0`) license.

- **Non-Commercial**: The artifacts are for non-commercial use only.
- **ShareAlike**: Remixes or adaptations must be distributed under the same license.
- **No commercial rights via code license**: The repository source code is Apache-2.0, but that does not grant commercial rights to these artifacts.

## Background-removal model

The following background-removal model is also bundled under `models/`:

- `background_removal.onnx`

This model is distributed under the BSD 3-Clause License, copyright (c) 2025
Netesh Paudel. The complete notice is preserved in
[`models/BACKGROUND_REMOVER_LICENSE.txt`](models/BACKGROUND_REMOVER_LICENSE.txt).

The ONNX model was recovered from the historical CropCheckUp browser
implementation at commit
[`b8036567f6af4208d61202167a3022549ebfdc75`](https://github.com/rasagyavatsal/CropCheckUp/tree/b8036567f6af4208d61202167a3022549ebfdc75).
This is the model previously used for app inputs; its identity as the model
used to prepare the training dataset has not been established.
