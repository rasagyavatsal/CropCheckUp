/// <reference types="vite/client" />

/** The released version, from package.json. */
declare const __APP_VERSION__: string;

interface ImportMetaEnv {
  /** Where to download the classifier model; defaults to `models/plant_disease_model.onnx` beside the app. */
  readonly VITE_CLASSIFIER_URL?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
