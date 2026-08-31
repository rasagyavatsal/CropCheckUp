import { DiagnosisResult } from '../models/diagnosisResult';
import type { DiseaseInfo } from '../types/diagnosis';

const MODEL_URL = '/models/plant_disease_model.tflite';
const LABELS_URL = '/models/labels.txt';
const DISEASE_INFO_URL = '/models/disease_info.json';
// Vendored TensorFlow.js TFLite web client; load it only in the browser.
const TFLITE_RUNTIME_URL = '/models/tflite_web_api_client.js';
const INPUT_SIZE = 224;
const LABEL_COUNT = 68;
const CONFIDENCE_THRESHOLD = 0;

type TFLiteData = Int8Array | Uint8Array | Int16Array | Int32Array | Uint32Array | Float32Array | Float64Array;

type TFLiteTensorInfo = {
  dataType: string;
  shape: string;
  data: () => TFLiteData;
};

type TFLiteModelRunner = {
  getInputs: () => TFLiteTensorInfo[];
  getOutputs: () => TFLiteTensorInfo[];
  infer: () => boolean;
};

type TFLiteRuntime = {
  tflite_web_api: {
    setWasmPath: (path: string) => void;
  };
  TFLiteWebModelRunner: {
    create: (model: string | ArrayBuffer, options: { numThreads: number }) => Promise<TFLiteModelRunner>;
  };
};

declare global {
  interface Window {
    tfweb?: TFLiteRuntime;
  }
}

let modelPromise: Promise<TFLiteModelRunner> | undefined;
let runtimePromise: Promise<TFLiteRuntime> | undefined;

/** Runs the same 224 x 224, 0-255 RGB TFLite input contract in the browser. */
export class PlantClassifier {
  private labels: string[] = [];
  private diseaseInfo: Record<string, DiseaseInfo> = {};
  private isLoaded = false;

  async initialize(): Promise<void> {
    if (this.isLoaded) {
      return;
    }

    const runtime = await loadRuntime();
    runtime.tflite_web_api.setWasmPath(`${window.location.origin}/models/`);
    const [labels, diseaseInfo, model] = await Promise.all([
      loadLabels(),
      loadDiseaseInfo(),
      loadModel(runtime),
    ]);
    this.labels = labels;
    this.diseaseInfo = diseaseInfo;
    modelPromise = Promise.resolve(model);
    this.isLoaded = true;
  }

  async classifyImage(canvas: HTMLCanvasElement): Promise<DiagnosisResult | null> {
    if (!this.isLoaded || this.labels.length === 0) {
      throw new Error('PlantClassifier.initialize() must complete before inference.');
    }

    const runtime = await loadRuntime();
    const model = await loadModel(runtime);
    const inputInfo = model.getInputs()[0];
    const outputInfo = model.getOutputs()[0];
    if (!inputInfo || !outputInfo) {
      throw new Error('The classifier model has no input or output tensor.');
    }
    if (inputInfo.dataType !== 'float32' || inputInfo.shape !== '1,224,224,3') {
      throw new Error(`The classifier input contract is ${inputInfo.shape} ${inputInfo.dataType}; expected 1,224,224,3 float32.`);
    }

    const inputData = inputInfo.data();
    const rgb = createInputData(canvas);
    if (inputData.length !== rgb.length) {
      throw new Error(`The classifier input has ${inputData.length} values; expected ${rgb.length}.`);
    }
    for (let index = 0; index < rgb.length; index += 1) {
      inputData[index] = rgb[index] ?? 0;
    }

    if (!model.infer()) {
      throw new Error('The TensorFlow Lite classifier could not run inference.');
    }

    const scores = Array.from(outputInfo.data());
    if (scores.length !== this.labels.length) {
      throw new Error(`The classifier returned ${scores.length} scores; expected ${this.labels.length}.`);
    }

    let maxScore = Number.NEGATIVE_INFINITY;
    let maxIndex = -1;
    scores.forEach((score, index) => {
      if (Number.isFinite(score) && score > maxScore) {
        maxScore = score;
        maxIndex = index;
      }
    });

    if (maxIndex < 0 || maxScore < CONFIDENCE_THRESHOLD || !this.labels[maxIndex]) {
      return null;
    }

    const rawLabel = this.labels[maxIndex];
    return DiagnosisResult.fromPrediction(rawLabel, maxScore, this.diseaseInfo[rawLabel]);
  }
}

async function loadRuntime(): Promise<TFLiteRuntime> {
  if (window.tfweb?.TFLiteWebModelRunner) {
    return window.tfweb;
  }
  if (!runtimePromise) {
    runtimePromise = new Promise<TFLiteRuntime>((resolve, reject) => {
      const script = document.createElement('script');
      script.src = TFLITE_RUNTIME_URL;
      script.async = true;
      script.dataset.tfliteRuntime = 'true';
      script.onload = () => {
        if (window.tfweb?.TFLiteWebModelRunner) {
          resolve(window.tfweb);
        } else {
          reject(new Error('The TFLite browser runtime exposed no model runner.'));
        }
      };
      script.onerror = () => reject(new Error(`Could not load ${TFLITE_RUNTIME_URL}.`));
      document.head.appendChild(script);
    }).catch((error: unknown) => {
      runtimePromise = undefined;
      throw new Error(`Browser inference runtime could not be loaded: ${errorMessage(error)}`);
    });
  }
  return runtimePromise;
}

async function loadModel(runtime: TFLiteRuntime): Promise<TFLiteModelRunner> {
  if (!modelPromise) {
    runtime.tflite_web_api.setWasmPath(`${window.location.origin}/models/`);
    modelPromise = runtime.TFLiteWebModelRunner.create(MODEL_URL, { numThreads: 1 }).catch((error: unknown) => {
      modelPromise = undefined;
      throw new Error(`Plant-disease model could not be loaded: ${errorMessage(error)}`);
    });
  }
  return modelPromise;
}

async function loadLabels(): Promise<string[]> {
  const response = await fetch(LABELS_URL);
  if (!response.ok) {
    throw new Error(`Labels could not be loaded (${response.status}).`);
  }
  const labels = (await response.text())
    .split(/\r?\n/)
    .map((line) => line.trim())
    .filter(Boolean);
  if (labels.length !== LABEL_COUNT) {
    throw new Error(`The label file contains ${labels.length} labels; expected ${LABEL_COUNT}.`);
  }
  return labels;
}

async function loadDiseaseInfo(): Promise<Record<string, DiseaseInfo>> {
  const response = await fetch(DISEASE_INFO_URL);
  if (!response.ok) {
    throw new Error(`Disease information could not be loaded (${response.status}).`);
  }
  const value: unknown = await response.json();
  if (!isRecord(value)) {
    throw new Error('Disease information has an invalid format.');
  }
  return value as Record<string, DiseaseInfo>;
}

function createInputData(canvas: HTMLCanvasElement): Float32Array {
  const context = canvas.getContext('2d');
  if (!context) {
    throw new Error('The browser could not read the processed image.');
  }
  const pixels = context.getImageData(0, 0, INPUT_SIZE, INPUT_SIZE).data;
  const rgb = new Float32Array(INPUT_SIZE * INPUT_SIZE * 3);

  for (let index = 0; index < INPUT_SIZE * INPUT_SIZE; index += 1) {
    const rgbaIndex = index * 4;
    const isTransparent = (pixels[rgbaIndex + 3] ?? 0) === 0;
    const value = isTransparent ? 0 : 1;
    rgb[index * 3] = (pixels[rgbaIndex] ?? 0) * value;
    rgb[index * 3 + 1] = (pixels[rgbaIndex + 1] ?? 0) * value;
    rgb[index * 3 + 2] = (pixels[rgbaIndex + 2] ?? 0) * value;
  }

  return rgb;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
