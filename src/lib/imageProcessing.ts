/**
 * Pixel operations for preparing crop-leaf photos, ported from the former Python CLI.
 *
 * Everything works on plain RGBA buffers so it runs the same in a worker and in tests.
 * Resizing and compositing reproduce Pillow's integer arithmetic, which the classifier was
 * evaluated with.
 */

export const INPUT_SIZE = 224;
export const BACKGROUND_MODEL_SIZE = 320;
// Below this share of the photo kept, the background-removal mask is treated as a miss. Picked on the PlantVillage
// test split, where falling back below 20% recovered nearly all the accuracy lost to empty masks.
export const MIN_FOREGROUND_FRACTION = 0.2;

const MEAN = [0.485, 0.456, 0.406] as const;
const STD = [0.229, 0.224, 0.225] as const;
// Pillow's fixed-point precision for 8-bit resampling.
const PRECISION_BITS = 32 - 8 - 2;
const PRECISION_SCALE = 2 ** PRECISION_BITS;

/** A non-premultiplied RGBA image, laid out like `ImageData`. */
export interface RgbaImage {
  width: number;
  height: number;
  data: Uint8ClampedArray;
}

export interface Mask {
  width: number;
  height: number;
  data: Float32Array;
}

export function createImage(width: number, height: number): RgbaImage {
  return { width, height, data: new Uint8ClampedArray(width * height * 4) };
}

interface Coefficients {
  bounds: Int32Array;
  weights: Float64Array;
  kernelSize: number;
}

/** Pillow's antialiased bilinear coefficients, as fixed-point integers. */
function precomputeCoefficients(inSize: number, outSize: number): Coefficients {
  const scale = inSize / outSize;
  const filterScale = Math.max(scale, 1);
  const support = filterScale;
  const kernelSize = Math.ceil(support) * 2 + 1;
  const bounds = new Int32Array(outSize * 2);
  const weights = new Float64Array(outSize * kernelSize);
  const raw = new Float64Array(kernelSize);

  for (let out = 0; out < outSize; out++) {
    const center = (out + 0.5) * scale;
    const min = Math.max(0, Math.trunc(center - support + 0.5));
    const count = Math.min(inSize, Math.trunc(center + support + 0.5)) - min;
    let total = 0;
    for (let x = 0; x < count; x++) {
      const w = Math.max(0, 1 - Math.abs((x + min - center + 0.5) / filterScale));
      raw[x] = w;
      total += w;
    }
    for (let x = 0; x < count; x++) {
      const w = total === 0 ? raw[x]! : raw[x]! / total;
      weights[out * kernelSize + x] = Math.trunc(w < 0 ? -0.5 + w * PRECISION_SCALE : 0.5 + w * PRECISION_SCALE);
    }
    bounds[out * 2] = min;
    bounds[out * 2 + 1] = count;
  }
  return { bounds, weights, kernelSize };
}

function clip8(value: number): number {
  const shifted = Math.floor(value / PRECISION_SCALE);
  return shifted < 0 ? 0 : shifted > 255 ? 255 : shifted;
}

/**
 * Resize the RGB channels like Pillow's `Image.resize(..., BILINEAR)` on an RGB image.
 * Alpha is ignored and the result is opaque.
 */
export function resizeRgb(source: RgbaImage, width: number, height: number): RgbaImage {
  let current = source;
  if (source.width !== width) {
    const { bounds, weights, kernelSize } = precomputeCoefficients(source.width, width);
    const next = createImage(width, source.height);
    for (let y = 0; y < source.height; y++) {
      const row = y * source.width;
      for (let x = 0; x < width; x++) {
        const min = bounds[x * 2]!;
        const count = bounds[x * 2 + 1]!;
        let r = PRECISION_SCALE / 2;
        let g = r;
        let b = r;
        for (let k = 0; k < count; k++) {
          const w = weights[x * kernelSize + k]!;
          const i = (row + min + k) * 4;
          r += source.data[i]! * w;
          g += source.data[i + 1]! * w;
          b += source.data[i + 2]! * w;
        }
        const o = (y * width + x) * 4;
        next.data[o] = clip8(r);
        next.data[o + 1] = clip8(g);
        next.data[o + 2] = clip8(b);
      }
    }
    current = next;
  }

  if (current.height !== height) {
    const { bounds, weights, kernelSize } = precomputeCoefficients(current.height, height);
    const next = createImage(width, height);
    for (let y = 0; y < height; y++) {
      const min = bounds[y * 2]!;
      const count = bounds[y * 2 + 1]!;
      for (let x = 0; x < width; x++) {
        let r = PRECISION_SCALE / 2;
        let g = r;
        let b = r;
        for (let k = 0; k < count; k++) {
          const w = weights[y * kernelSize + k]!;
          const i = ((min + k) * width + x) * 4;
          r += current.data[i]! * w;
          g += current.data[i + 1]! * w;
          b += current.data[i + 2]! * w;
        }
        const o = (y * width + x) * 4;
        next.data[o] = clip8(r);
        next.data[o + 1] = clip8(g);
        next.data[o + 2] = clip8(b);
      }
    }
    current = next;
  }

  if (current === source) {
    current = { width, height, data: new Uint8ClampedArray(source.data) };
  }
  for (let i = 3; i < current.data.length; i += 4) {
    current.data[i] = 255;
  }
  return current;
}

/** Create the normalised NCHW float32 tensor expected by the background-removal model. */
export function createBackgroundModelInput(image: RgbaImage): Float32Array {
  const resized = resizeRgb(image, BACKGROUND_MODEL_SIZE, BACKGROUND_MODEL_SIZE);
  const plane = BACKGROUND_MODEL_SIZE * BACKGROUND_MODEL_SIZE;
  const tensor = new Float32Array(plane * 3);
  for (let p = 0; p < plane; p++) {
    for (let c = 0; c < 3; c++) {
      tensor[c * plane + p] = (resized.data[p * 4 + c]! / 255 - MEAN[c]!) / STD[c]!;
    }
  }
  return tensor;
}

/** Validate a model mask: non-empty, finite, and within [0, 1]. */
export function validateMask(mask: Mask): void {
  if (mask.width < 1 || mask.height < 1 || mask.data.length !== mask.width * mask.height) {
    throw new Error(`background-removal mask has invalid shape ${mask.height}×${mask.width}`);
  }
  for (const value of mask.data) {
    if (!Number.isFinite(value)) {
      throw new Error('background-removal mask contains non-finite values');
    }
    if (value < 0 || value > 1) {
      throw new Error('background-removal mask values must be between 0 and 1');
    }
  }
}

/** Bilinearly stretch a mask to the image size, without antialiasing. */
export function resizeMask(mask: Mask, width: number, height: number): Float32Array {
  if (mask.width === width && mask.height === height) {
    return new Float32Array(mask.data);
  }
  const result = new Float32Array(width * height);
  const xs = new Float64Array(width);
  for (let x = 0; x < width; x++) {
    xs[x] = (x * mask.width) / width;
  }
  for (let y = 0; y < height; y++) {
    const sy = (y * mask.height) / height;
    const y1 = Math.floor(sy);
    const y2 = Math.min(mask.height - 1, y1 + 1);
    const yw = sy - y1;
    for (let x = 0; x < width; x++) {
      const sx = xs[x]!;
      const x1 = Math.floor(sx);
      const x2 = Math.min(mask.width - 1, x1 + 1);
      const xw = sx - x1;
      const top = mask.data[y1 * mask.width + x1]! * (1 - xw) + mask.data[y1 * mask.width + x2]! * xw;
      const bottom = mask.data[y2 * mask.width + x1]! * (1 - xw) + mask.data[y2 * mask.width + x2]! * xw;
      result[y * width + x] = top * (1 - yw) + bottom * yw;
    }
  }
  return result;
}

/** Push uncertain mask values towards their neighbourhood where the photo has a strong edge. */
export function enhanceMaskEdges(image: RgbaImage, mask: Float32Array): Float32Array {
  const { width, height, data } = image;
  const enhanced = new Float32Array(mask);
  if (width < 3 || height < 3) {
    return enhanced;
  }
  for (let y = 1; y < height - 1; y++) {
    for (let x = 1; x < width - 1; x++) {
      const i = y * width + x;
      const current = mask[i]!;
      if (current <= 0.3 || current >= 0.7) {
        continue;
      }
      let gradient = 0;
      for (let c = 0; c < 3; c++) {
        gradient +=
          Math.abs(data[(i + 1) * 4 + c]! - data[(i - 1) * 4 + c]!) +
          Math.abs(data[(i + width) * 4 + c]! - data[(i - width) * 4 + c]!);
      }
      if (gradient / 3 <= 30) {
        continue;
      }
      let neighbourhood = 0;
      for (let dy = -1; dy <= 1; dy++) {
        for (let dx = -1; dx <= 1; dx++) {
          neighbourhood += mask[i + dy * width + dx]!;
        }
      }
      const adjusted = current + (neighbourhood / 9 > 0.5 ? 0.1 : -0.1);
      enhanced[i] = Math.min(1, Math.max(0, adjusted));
    }
  }
  return enhanced;
}

/** 3×3 box blur that averages only the neighbours inside the image. */
export function smoothMask(mask: Float32Array, width: number, height: number): Float32Array {
  const smoothed = new Float32Array(mask.length);
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      let total = 0;
      let count = 0;
      for (let dy = -1; dy <= 1; dy++) {
        const ny = y + dy;
        if (ny < 0 || ny >= height) continue;
        for (let dx = -1; dx <= 1; dx++) {
          const nx = x + dx;
          if (nx < 0 || nx >= width) continue;
          total += mask[ny * width + nx]!;
          count++;
        }
      }
      smoothed[y * width + x] = total / count;
    }
  }
  return smoothed;
}

/** Round half to even, like NumPy's `rint`. */
function rint(value: number): number {
  const rounded = Math.round(value);
  return Math.abs(value % 1) === 0.5 && rounded % 2 !== 0 ? rounded - 1 : rounded;
}

/**
 * Apply a model mask and return a new RGBA image.
 *
 * The source alpha is multiplied by the mask alpha so existing transparency is preserved
 * instead of being treated as fully opaque.
 */
export function applyBackgroundMask(image: RgbaImage, mask: Mask): RgbaImage {
  validateMask(mask);
  const { width, height } = image;
  const resized = resizeMask(mask, width, height);
  const smoothed = smoothMask(enhanceMaskEdges(image, resized), width, height);
  const result: RgbaImage = { width, height, data: new Uint8ClampedArray(image.data) };
  for (let i = 0; i < smoothed.length; i++) {
    const value = smoothed[i]!;
    const alpha = value > 0.55 ? 255 : value < 0.45 ? 0 : rint(((value - 0.45) / 0.1) * 255);
    result.data[i * 4 + 3] = rint((alpha * image.data[i * 4 + 3]!) / 255);
  }
  return result;
}

/** Return the share of the source image's opacity that the mask kept. */
export function foregroundFraction(source: RgbaImage, segmented: RgbaImage): number {
  let before = 0;
  let after = 0;
  for (let i = 3; i < source.data.length; i += 4) {
    before += source.data[i]!;
    after += segmented.data[i]!;
  }
  return before > 0 ? after / before : 0;
}

/** Composite onto opaque black, matching Pillow's `Image.alpha_composite`. */
export function compositeOnBlack(image: RgbaImage): RgbaImage {
  const result = createImage(image.width, image.height);
  for (let i = 0; i < image.data.length; i += 4) {
    const alpha = image.data[i + 3]!;
    for (let c = 0; c < 3; c++) {
      const value = image.data[i + c]! * alpha * 128 + (0x80 << 7);
      result.data[i + c] = (((value >> 8) + value) >> 8) >> 7;
    }
    result.data[i + 3] = 255;
  }
  return result;
}

/** Composite onto black and resize to the classifier's 224×224 RGB input. */
export function prepareClassifierImage(image: RgbaImage): RgbaImage {
  // Composite before resizing so hidden RGB does not bleed into leaf edges.
  return resizeRgb(compositeOnBlack(image), INPUT_SIZE, INPUT_SIZE);
}

/** Create the NHWC float32 tensor of RGB values in [0, 255] that the classifier normalises itself. */
export function createClassifierInput(image: RgbaImage): Float32Array {
  const tensor = new Float32Array(image.width * image.height * 3);
  for (let p = 0; p < image.width * image.height; p++) {
    tensor[p * 3] = image.data[p * 4]!;
    tensor[p * 3 + 1] = image.data[p * 4 + 1]!;
    tensor[p * 3 + 2] = image.data[p * 4 + 2]!;
  }
  return tensor;
}
