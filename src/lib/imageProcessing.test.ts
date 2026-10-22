import { describe, expect, it } from 'vitest';

import {
  applyBackgroundMask,
  BACKGROUND_MODEL_SIZE,
  compositeOnBlack,
  createBackgroundModelInput,
  createClassifierInput,
  createImage,
  foregroundFraction,
  prepareClassifierImage,
  resizeMask,
  resizeRgb,
  smoothMask,
  type RgbaImage,
} from './imageProcessing';

/** A 6×4 image with varied colours and alpha; expected values below come from Pillow. */
function pattern(): RgbaImage {
  const image = createImage(6, 4);
  for (let i = 0; i < 24; i++) {
    image.data.set([(i * 37) % 256, (i * 91 + 17) % 256, (i * 53 + 101) % 256, (i * 29) % 256], i * 4);
  }
  return image;
}

function solid(width: number, height: number, rgba: [number, number, number, number]): RgbaImage {
  const image = createImage(width, height);
  for (let i = 0; i < width * height; i++) {
    image.data.set(rgba, i * 4);
  }
  return image;
}

function rgb(image: RgbaImage): number[] {
  return Array.from(image.data).filter((_, index) => index % 4 !== 3);
}

describe('resizeRgb', () => {
  it('matches Pillow when downscaling', () => {
    expect(rgb(resizeRgb(pattern(), 4, 3))).toEqual([
      52, 61, 140, 56, 160, 143, 109, 93, 54, 161, 192, 109, 171, 102, 166, 58, 130, 75, 68, 120, 109, 120, 153,
      183, 178, 143, 80, 159, 100, 106, 47, 146, 183, 79, 114, 145,
    ]);
  });

  it('matches Pillow when upscaling', () => {
    expect(rgb(resizeRgb(pattern(), 9, 5)).slice(0, 27)).toEqual([
      0, 17, 101, 19, 63, 128, 43, 123, 163, 68, 184, 198, 93, 117, 106, 117, 49, 13, 142, 110, 48, 167, 171, 84,
      185, 216, 110,
    ]);
  });

  it('returns an opaque copy at the same size', () => {
    const source = pattern();
    const resized = resizeRgb(source, 6, 4);
    expect(resized.data).not.toBe(source.data);
    expect(rgb(resized)).toEqual(rgb(source));
    expect(resized.data[3]).toBe(255);
  });
});

describe('compositeOnBlack', () => {
  it('matches Pillow alpha compositing', () => {
    expect(rgb(compositeOnBlack(pattern())).slice(0, 18)).toEqual([0, 0, 0, 4, 12, 18, 17, 45, 47, 38, 12, 1, 67, 57, 26, 105, 123, 63]);
  });
});

describe('createBackgroundModelInput', () => {
  it('returns normalised NCHW values', () => {
    const tensor = createBackgroundModelInput(solid(10, 8, [255, 0, 128, 255]));
    const plane = BACKGROUND_MODEL_SIZE * BACKGROUND_MODEL_SIZE;
    expect(tensor).toHaveLength(plane * 3);
    expect(tensor[0]).toBeCloseTo((1 - 0.485) / 0.229, 5);
    expect(tensor[plane]).toBeCloseTo((0 - 0.456) / 0.224, 5);
    expect(tensor[plane * 2 + 5]).toBeCloseTo((128 / 255 - 0.406) / 0.225, 5);
  });
});

describe('background mask', () => {
  it('stretches a mask bilinearly', () => {
    const resized = resizeMask({ width: 2, height: 1, data: new Float32Array([0, 1]) }, 4, 1);
    expect(Array.from(resized)).toEqual([0, 0.5, 1, 1]);
  });

  it('averages only neighbours inside the image', () => {
    const smoothed = smoothMask(new Float32Array([1, 0, 0, 0]), 2, 2);
    expect(Array.from(smoothed)).toEqual([0.25, 0.25, 0.25, 0.25]);
  });

  it('keeps the foreground and preserves existing transparency', () => {
    const image = solid(4, 4, [10, 20, 30, 128]);
    const masked = applyBackgroundMask(image, { width: 1, height: 1, data: new Float32Array([1]) });
    expect(masked.data[3]).toBe(128);
    expect(foregroundFraction(image, masked)).toBe(1);
  });

  it('removes the background', () => {
    const image = solid(4, 4, [10, 20, 30, 255]);
    const masked = applyBackgroundMask(image, { width: 1, height: 1, data: new Float32Array([0]) });
    expect(masked.data[3]).toBe(0);
    expect(foregroundFraction(image, masked)).toBe(0);
  });

  it('rejects invalid masks', () => {
    const image = solid(2, 2, [0, 0, 0, 255]);
    expect(() => applyBackgroundMask(image, { width: 1, height: 1, data: new Float32Array([1.5]) })).toThrow('between 0 and 1');
    expect(() => applyBackgroundMask(image, { width: 1, height: 1, data: new Float32Array([Number.NaN]) })).toThrow('non-finite');
    expect(() => applyBackgroundMask(image, { width: 2, height: 1, data: new Float32Array([1]) })).toThrow('invalid shape');
  });

  it('reports no foreground for a fully transparent source', () => {
    const image = solid(2, 2, [0, 0, 0, 0]);
    expect(foregroundFraction(image, image)).toBe(0);
  });
});

describe('classifier input', () => {
  it('composites onto black, resizes to 224×224 and keeps values in [0, 255]', () => {
    const processed = prepareClassifierImage(solid(300, 100, [200, 100, 50, 255]));
    expect([processed.width, processed.height]).toEqual([224, 224]);
    const tensor = createClassifierInput(processed);
    expect(tensor).toHaveLength(224 * 224 * 3);
    expect(Array.from(tensor.slice(0, 3))).toEqual([200, 100, 50]);
  });
});
