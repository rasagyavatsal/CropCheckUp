import type * as ortTypes from 'onnxruntime-web';

import {
  BACKGROUND_MODEL_SIZE,
  canvasToDataUrl,
} from './imageProcessing';

const MODEL_URL = '/models/background_removal.onnx';
const MODEL_INPUT_NAME = 'input.1';
const MEAN = [0.485, 0.456, 0.406] as const;
const STD = [0.229, 0.224, 0.225] as const;

type OrtRuntime = typeof import('onnxruntime-web/wasm');

let runtimePromise: Promise<OrtRuntime> | undefined;
let sessionPromise: Promise<ortTypes.InferenceSession> | undefined;

/**
 * Browser equivalent of the former ONNX background-removal service.
 *
 * The model and ONNX WASM runtime are served by the website itself. No image
 * bytes leave the browser during segmentation.
 */
export class BackgroundRemovalService {
  async initialize(): Promise<void> {
    await this.getSession();
  }

  async removeBackground(source: HTMLCanvasElement): Promise<HTMLCanvasElement> {
    const [session, ort] = await Promise.all([this.getSession(), loadRuntime()]);
    const modelInput = createModelInput(source);
    const tensor = new ort.Tensor(
      'float32',
      modelInput.data,
      [1, 3, BACKGROUND_MODEL_SIZE, BACKGROUND_MODEL_SIZE],
    );

    const outputs = await session.run({ [MODEL_INPUT_NAME]: tensor });
    const output = outputs[session.outputNames[0] ?? ''];
    if (!output) {
      throw new Error('The background-removal model returned no mask.');
    }

    const mask = Array.from(output.data as Float32Array);
    return applyMask(source, mask, modelOutputWidth(output), modelOutputHeight(output));
  }

  private async getSession(): Promise<ortTypes.InferenceSession> {
    if (!sessionPromise) {
      sessionPromise = loadRuntime().then((ort) => {
        configureRuntime(ort);
        return ort.InferenceSession.create(MODEL_URL, {
          executionProviders: ['wasm'],
          graphOptimizationLevel: 'all',
        });
      }).catch((error: unknown) => {
        sessionPromise = undefined;
        throw new Error(`Background-removal model could not be loaded: ${errorMessage(error)}`);
      });
    }
    return sessionPromise;
  }
}

async function loadRuntime(): Promise<OrtRuntime> {
  if (!runtimePromise) {
    runtimePromise = import('onnxruntime-web/wasm').catch((error: unknown) => {
      runtimePromise = undefined;
      throw new Error(`Browser segmentation runtime could not be loaded: ${errorMessage(error)}`);
    });
  }
  return runtimePromise;
}

function configureRuntime(ort: OrtRuntime): void {
  // Keep the runtime compatible with a normal local static server. Threaded WASM
  // requires cross-origin isolation, so the single-threaded configuration is a
  // safer default for local development.
  ort.env.wasm.wasmPaths = '/models/';
  ort.env.wasm.numThreads = 1;
  ort.env.wasm.proxy = false;
}

function createModelInput(source: HTMLCanvasElement): { data: Float32Array } {
  const canvas = document.createElement('canvas');
  canvas.width = BACKGROUND_MODEL_SIZE;
  canvas.height = BACKGROUND_MODEL_SIZE;
  const context = canvas.getContext('2d');
  if (!context) {
    throw new Error('The browser could not create a segmentation canvas.');
  }
  context.imageSmoothingEnabled = true;
  context.imageSmoothingQuality = 'high';
  context.drawImage(source, 0, 0, BACKGROUND_MODEL_SIZE, BACKGROUND_MODEL_SIZE);

  const pixels = context.getImageData(0, 0, BACKGROUND_MODEL_SIZE, BACKGROUND_MODEL_SIZE).data;
  const pixelCount = BACKGROUND_MODEL_SIZE * BACKGROUND_MODEL_SIZE;
  const values = new Float32Array(pixelCount * 3);

  for (let index = 0; index < pixelCount; index += 1) {
    const rgbaIndex = index * 4;
    values[index] = normalize(pixels[rgbaIndex] ?? 0, MEAN[0], STD[0]);
    values[pixelCount + index] = normalize(pixels[rgbaIndex + 1] ?? 0, MEAN[1], STD[1]);
    values[pixelCount * 2 + index] = normalize(pixels[rgbaIndex + 2] ?? 0, MEAN[2], STD[2]);
  }

  return { data: values };
}

function normalize(value: number, mean: number, std: number): number {
  return (value / 255 - mean) / std;
}

function modelOutputWidth(output: ortTypes.Tensor): number {
  return output.dims.at(-1) ?? BACKGROUND_MODEL_SIZE;
}

function modelOutputHeight(output: ortTypes.Tensor): number {
  return output.dims.at(-2) ?? BACKGROUND_MODEL_SIZE;
}

function applyMask(
  source: HTMLCanvasElement,
  mask: number[],
  maskWidth: number,
  maskHeight: number,
): HTMLCanvasElement {
  const context = source.getContext('2d');
  if (!context) {
    throw new Error('The browser could not read the selected image.');
  }

  const image = context.getImageData(0, 0, source.width, source.height);
  const resizedMask = resizeMask(mask, maskWidth, maskHeight, source.width, source.height);
  const enhancedMask = enhanceMaskEdges(image.data, resizedMask, source.width, source.height);
  const smoothedMask = smoothMask(enhancedMask, source.width, source.height);

  for (let y = 0; y < source.height; y += 1) {
    for (let x = 0; x < source.width; x += 1) {
      const pixelIndex = y * source.width + x;
      const maskValue = smoothedMask[pixelIndex] ?? 0;
      const alpha = maskValue > 0.55
        ? 255
        : maskValue < 0.45
          ? 0
          : Math.round(((maskValue - 0.45) / 0.1) * 255);
      image.data[pixelIndex * 4 + 3] = alpha;
    }
  }

  const output = document.createElement('canvas');
  output.width = source.width;
  output.height = source.height;
  const outputContext = output.getContext('2d');
  if (!outputContext) {
    throw new Error('The browser could not create the processed image.');
  }
  outputContext.putImageData(image, 0, 0);
  // Calling toDataURL here validates that the browser can encode the same PNG
  // representation used by preview, inference, and history.
  canvasToDataUrl(output);
  return output;
}

function resizeMask(
  mask: number[],
  maskWidth: number,
  maskHeight: number,
  width: number,
  height: number,
): number[] {
  const resized = new Array<number>(width * height);
  for (let y = 0; y < height; y += 1) {
    const sourceY = (y * maskHeight) / height;
    const y1 = Math.min(maskHeight - 1, Math.floor(sourceY));
    const y2 = Math.min(maskHeight - 1, y1 + 1);
    const yWeight = sourceY - y1;

    for (let x = 0; x < width; x += 1) {
      const sourceX = (x * maskWidth) / width;
      const x1 = Math.min(maskWidth - 1, Math.floor(sourceX));
      const x2 = Math.min(maskWidth - 1, x1 + 1);
      const xWeight = sourceX - x1;
      const top = interpolate(mask[y1 * maskWidth + x1] ?? 0, mask[y1 * maskWidth + x2] ?? 0, xWeight);
      const bottom = interpolate(mask[y2 * maskWidth + x1] ?? 0, mask[y2 * maskWidth + x2] ?? 0, xWeight);
      resized[y * width + x] = interpolate(top, bottom, yWeight);
    }
  }
  return resized;
}

function interpolate(first: number, second: number, weight: number): number {
  return first * (1 - weight) + second * weight;
}

function enhanceMaskEdges(
  rgba: Uint8ClampedArray,
  mask: number[],
  width: number,
  height: number,
): number[] {
  const enhanced = [...mask];
  for (let y = 1; y < height - 1; y += 1) {
    for (let x = 1; x < width - 1; x += 1) {
      const left = (y * width + x - 1) * 4;
      const right = (y * width + x + 1) * 4;
      const up = ((y - 1) * width + x) * 4;
      const down = ((y + 1) * width + x) * 4;
      const gradientRed = Math.abs((rgba[right] ?? 0) - (rgba[left] ?? 0)) + Math.abs((rgba[down] ?? 0) - (rgba[up] ?? 0));
      const gradientGreen = Math.abs((rgba[right + 1] ?? 0) - (rgba[left + 1] ?? 0)) + Math.abs((rgba[down + 1] ?? 0) - (rgba[up + 1] ?? 0));
      const gradientBlue = Math.abs((rgba[right + 2] ?? 0) - (rgba[left + 2] ?? 0)) + Math.abs((rgba[down + 2] ?? 0) - (rgba[up + 2] ?? 0));
      const gradientMagnitude = (gradientRed + gradientGreen + gradientBlue) / 3;
      const current = mask[y * width + x] ?? 0;

      if (gradientMagnitude > 30 && current > 0.3 && current < 0.7) {
        let total = 0;
        let count = 0;
        for (let offsetY = -1; offsetY <= 1; offsetY += 1) {
          for (let offsetX = -1; offsetX <= 1; offsetX += 1) {
            total += mask[(y + offsetY) * width + x + offsetX] ?? 0;
            count += 1;
          }
        }
        const average = total / count;
        enhanced[y * width + x] = Math.max(0, Math.min(1, current + (average > 0.5 ? 0.1 : -0.1)));
      }
    }
  }
  return enhanced;
}

function smoothMask(mask: number[], width: number, height: number): number[] {
  const smoothed = new Array<number>(mask.length);
  for (let y = 0; y < height; y += 1) {
    for (let x = 0; x < width; x += 1) {
      let total = 0;
      let count = 0;
      for (let offsetY = -1; offsetY <= 1; offsetY += 1) {
        for (let offsetX = -1; offsetX <= 1; offsetX += 1) {
          const nextX = x + offsetX;
          const nextY = y + offsetY;
          if (nextX >= 0 && nextX < width && nextY >= 0 && nextY < height) {
            total += mask[nextY * width + nextX] ?? 0;
            count += 1;
          }
        }
      }
      smoothed[y * width + x] = count === 0 ? 0 : total / count;
    }
  }
  return smoothed;
}

function errorMessage(error: unknown): string {
  return error instanceof Error ? error.message : String(error);
}
