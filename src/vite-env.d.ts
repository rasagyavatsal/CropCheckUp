/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** Where to download the classifier model; defaults to `models/plant_disease_model.onnx` beside the app. */
  readonly VITE_CLASSIFIER_URL?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
