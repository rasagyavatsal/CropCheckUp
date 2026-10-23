# Changelog

## [2.0.0](https://github.com/rasagyavatsal/CropCheckUp/compare/v1.0.0...v2.0.0) (2026-10-23)


### ⚠ BREAKING CHANGES

* the `cropcheckup` command and Python package are removed.
* the classifier asset is plant_disease_model.onnx, which is not in the repository, and labels.txt has 38 PlantVillage labels instead of 68; the mango, papaya, bottle gourd and zucchini labels are gone.

### Features

* add classification pipeline and model validation ([f776773](https://github.com/rasagyavatsal/CropCheckUp/commit/f776773588c0f800afdb37a1b8aa1fd82542c499))
* add label parsing and prediction ranking ([1c7b0e2](https://github.com/rasagyavatsal/CropCheckUp/commit/1c7b0e22d865fa89d3fee14e0da3b2622834d757))
* add leaf photo upload and results UI ([30a102b](https://github.com/rasagyavatsal/CropCheckUp/commit/30a102b344303aecc8997096a86ca6c3585008de))
* classify the whole photo when background removal keeps too little ([936a604](https://github.com/rasagyavatsal/CropCheckUp/commit/936a604c838c0da44355ee4ad269037aa6acdf42))
* deploy the web app to Cloud Run ([43482cf](https://github.com/rasagyavatsal/CropCheckUp/commit/43482cfa1d9be33ec70c888fabd82d34e17cb065))
* port image preprocessing and background masking ([eb1c990](https://github.com/rasagyavatsal/CropCheckUp/commit/eb1c990606ff5c0ef76fe22cdb4b49b9815c82bb))
* remove Python CLI ([bba9997](https://github.com/rasagyavatsal/CropCheckUp/commit/bba999757b2acd6da4ae94097c7b8a34babcb6ac))
* replace the Keras classifier with a local ConvNeXt ONNX model ([30e7a54](https://github.com/rasagyavatsal/CropCheckUp/commit/30e7a546bdf264e92e0815249bc24bba8c681f9a))
* replace the logo with a leaf whose vein is a check mark ([4a03a69](https://github.com/rasagyavatsal/CropCheckUp/commit/4a03a69a479dd24bdd6028afabb4f7fd27fff150))
* run the ONNX models in a web worker ([5b20ed1](https://github.com/rasagyavatsal/CropCheckUp/commit/5b20ed15d2a1e4d82e49cde270864a6628c4ea2c))
* show the app version in the footer ([e13ea16](https://github.com/rasagyavatsal/CropCheckUp/commit/e13ea168b628d13f569f459bdcc27a105dc8794a))


### Bug Fixes

* keep the dropzone highlighted while dragging over its contents ([bf4400b](https://github.com/rasagyavatsal/CropCheckUp/commit/bf4400b244a387f8af05136f06cb060921c61a4c))
* make the model file button reachable by keyboard ([fe7276e](https://github.com/rasagyavatsal/CropCheckUp/commit/fe7276e9cd2facbd0eaaa3381883829fa5b8a841))

## [1.0.0](https://github.com/rasagyavatsal/CropCheckUp/compare/v0.0.1...v1.0.0) (2026-09-27)


### ⚠ BREAKING CHANGES

* Run python cli.py instead of python cropcheckup.py and import classifier functions from classifier.
* Custom model directories must provide plant_disease_model.keras instead of a TFLite model. Install the TensorFlow runtime dependencies using a supported Python version.

### Features

* **cli:** add local background removal for classification ([#122](https://github.com/rasagyavatsal/CropCheckUp/issues/122)) ([f5bad20](https://github.com/rasagyavatsal/CropCheckUp/commit/f5bad20a74c5a0222bdb74b31f315d3ad0a00b06))
* implement training pipeline for plant disease classification with TensorFlow ([322cf36](https://github.com/rasagyavatsal/CropCheckUp/commit/322cf368ecb4b04b08a726d369b524535df2c4d4))
* **landing:** migrate site to React and TypeScript ([a39e64c](https://github.com/rasagyavatsal/CropCheckUp/commit/a39e64c83493d11a88a80c378ee83977b80e826d))
* **landing:** migrate site to React and TypeScript ([a1d8929](https://github.com/rasagyavatsal/CropCheckUp/commit/a1d89295ae91ce7c62feccd2cd28aa3e9a708358))
* migrate CLI inference and model export to Keras ([#118](https://github.com/rasagyavatsal/CropCheckUp/issues/118)) ([2f78d57](https://github.com/rasagyavatsal/CropCheckUp/commit/2f78d57b246a98e4fcf93411e19ab64292545c26))
* package CropCheckUp under src ([#125](https://github.com/rasagyavatsal/CropCheckUp/issues/125)) ([a1fb4dc](https://github.com/rasagyavatsal/CropCheckUp/commit/a1fb4dc43114ece99e286cc6a9687a63e5b6e4c7))


### Bug Fixes

* add AGENTS.md to .gitignore ([80a6558](https://github.com/rasagyavatsal/CropCheckUp/commit/80a6558703a6ff8c9eb56adfbd88a485e1e8d8fb))


### Code Refactoring

* split CLI and classifier modules ([#123](https://github.com/rasagyavatsal/CropCheckUp/issues/123)) ([5ba268f](https://github.com/rasagyavatsal/CropCheckUp/commit/5ba268f3026e3b8a9203419e4ad02222720c1db1))
