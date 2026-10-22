/// <reference lib="webworker" />
import * as ort from 'onnxruntime-web/wasm';
import wasmUrl from 'onnxruntime-web/ort-wasm-simd-threaded.wasm?url';

import diseaseInfo from '../data/disease_info.json';
import labelsText from '../data/labels.txt?raw';
import { classifyImage } from '../lib/classify';
import type { RgbaImage } from '../lib/imageProcessing';
import { parseLabels } from '../lib/labels';
import { validateBackgroundModel, validateClassifier } from '../lib/modelValidation';
import { createModels } from '../lib/ortModels';
import type { WorkerRequest, WorkerResponse } from './protocol';

declare const self: DedicatedWorkerGlobalScope;

ort.env.wasm.wasmPaths = { wasm: wasmUrl };
// Threaded WebAssembly would start more workers from this bundle; one thread keeps the worker self-contained.
ort.env.wasm.numThreads = 1;

const labels = parseLabels(labelsText);
const sessionOptions: ort.InferenceSession.SessionOptions = {
  executionProviders: ['wasm'],
  graphOptimizationLevel: 'all',
};

let backgroundSession: ort.InferenceSession | undefined;
let classifierSession: ort.InferenceSession | undefined;

class MissingClassifierError extends Error {}

function post(response: WorkerResponse, transfer: Transferable[] = []): void {
  self.postMessage(response, transfer);
}

async function download(url: string, onProgress: (loaded: number, total: number) => void): Promise<Uint8Array> {
  const response = await fetch(url);
  // Development servers answer unknown paths with the app's HTML page.
  if (response.status === 404 || response.headers.get('content-type')?.includes('text/html')) {
    throw new MissingClassifierError(`model not found: ${url}`);
  }
  if (!response.ok || !response.body) {
    throw new Error(`could not download ${url}: HTTP ${response.status}`);
  }
  const total = Number(response.headers.get('content-length')) || 0;
  const chunks: Uint8Array[] = [];
  let loaded = 0;
  const reader = response.body.getReader();
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    chunks.push(value);
    loaded += value.byteLength;
    onProgress(loaded, total);
  }
  const bytes = new Uint8Array(loaded);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }
  return bytes;
}

async function createClassifier(model: Uint8Array): Promise<ort.InferenceSession> {
  let session: ort.InferenceSession;
  try {
    session = await ort.InferenceSession.create(model, sessionOptions);
  } catch (error) {
    throw new Error(`could not load classifier model: ${messageOf(error)}`);
  }
  validateClassifier(session.inputMetadata, session.outputMetadata);
  return session;
}

async function createBackgroundModel(url: string): Promise<ort.InferenceSession> {
  let session: ort.InferenceSession;
  try {
    session = await ort.InferenceSession.create(url, sessionOptions);
  } catch (error) {
    throw new Error(`could not load background-removal model: ${messageOf(error)}`);
  }
  validateBackgroundModel(session.inputMetadata, session.outputMetadata);
  return session;
}

async function decode(image: Blob): Promise<RgbaImage> {
  let bitmap: ImageBitmap;
  try {
    bitmap = await createImageBitmap(image, { imageOrientation: 'from-image', premultiplyAlpha: 'none' });
  } catch {
    throw new Error('this browser cannot read the image; try a JPEG, PNG or WebP file');
  }
  const canvas = new OffscreenCanvas(bitmap.width, bitmap.height);
  const context = canvas.getContext('2d', { willReadFrequently: true });
  if (!context) {
    throw new Error('could not create a canvas to read the image');
  }
  context.drawImage(bitmap, 0, 0);
  bitmap.close();
  const { width, height, data } = context.getImageData(0, 0, canvas.width, canvas.height);
  return { width, height, data };
}

function messageOf(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}

async function handle(request: WorkerRequest): Promise<void> {
  switch (request.type) {
    case 'load': {
      backgroundSession ??= await createBackgroundModel(request.urls.backgroundModel);
      if (!classifierSession) {
        const model = await download(request.urls.classifier, (loaded, total) =>
          post({ id: request.id, type: 'progress', loaded, total }),
        );
        classifierSession = await createClassifier(model);
      }
      post({ id: request.id, type: 'loaded' });
      return;
    }
    case 'load-classifier-file': {
      const session = await createClassifier(new Uint8Array(request.data));
      await classifierSession?.release();
      classifierSession = session;
      post({ id: request.id, type: 'loaded' });
      return;
    }
    case 'classify': {
      if (!backgroundSession || !classifierSession) {
        throw new Error('the models are not loaded yet');
      }
      const models = createModels(ort, backgroundSession, classifierSession, labels.length);
      const result = await classifyImage(await decode(request.image), models, labels, diseaseInfo);
      post({ id: request.id, type: 'result', result }, [result.processed.data.buffer]);
      return;
    }
  }
}

self.onmessage = (event: MessageEvent<WorkerRequest>) => {
  const request = event.data;
  handle(request).catch((error: unknown) => {
    post({
      id: request.id,
      type: 'error',
      message: messageOf(error),
      missingClassifier: error instanceof MissingClassifierError,
    });
  });
};
