import { describe, expect, it } from 'vitest';

import { classifyImage, type Models } from './classify';
import { createImage, type Mask } from './imageProcessing';

const labels = ['Tomato___Late_blight', 'Tomato___healthy', 'Potato___Early_blight'];
const info = { Tomato___Late_blight: { symptoms: 'Dark lesions' } };

function leaf() {
  const image = createImage(40, 30);
  for (let i = 0; i < 40 * 30; i++) {
    image.data.set([30, 160, 40, 255], i * 4);
  }
  return image;
}

function fakeModels(maskValue: number, received: Float32Array[] = []): Models {
  return {
    async segment(input): Promise<Mask> {
      expect(input).toHaveLength(3 * 320 * 320);
      return { width: 4, height: 4, data: new Float32Array(16).fill(maskValue) };
    },
    async classify(input) {
      received.push(input);
      return new Float32Array([0.1, 0.2, 0.7]);
    },
  };
}

describe('classifyImage', () => {
  it('ranks every label and attaches disease information', async () => {
    const result = await classifyImage(leaf(), fakeModels(1), labels, info);
    expect(result.predictions.map((prediction) => prediction.label)).toEqual([
      'Potato___Early_blight',
      'Tomato___healthy',
      'Tomato___Late_blight',
    ]);
    expect(result.predictions[2]?.symptoms).toBe('Dark lesions');
    expect(result.backgroundRemoved).toBe(true);
    expect([result.processed.width, result.processed.height]).toEqual([224, 224]);
  });

  it('classifies the whole photo when the mask keeps too little', async () => {
    const received: Float32Array[] = [];
    const result = await classifyImage(leaf(), fakeModels(0, received), labels, info);
    expect(result.backgroundRemoved).toBe(false);
    expect(result.foregroundFraction).toBe(0);
    expect(Array.from(received[0]!.slice(0, 3))).toEqual([30, 160, 40]);
  });

  it('composites the kept foreground onto black', async () => {
    const received: Float32Array[] = [];
    const models = fakeModels(1, received);
    models.segment = async () => {
      // Keep only the left half of the photo.
      const data = new Float32Array(16);
      for (let row = 0; row < 4; row++) data.set([1, 1, 0, 0], row * 4);
      return { width: 4, height: 4, data };
    };
    const result = await classifyImage(leaf(), models, labels, info);
    expect(result.backgroundRemoved).toBe(true);
    const lastPixel = received[0]!.slice(-3);
    expect(Array.from(lastPixel)).toEqual([0, 0, 0]);
  });
});
