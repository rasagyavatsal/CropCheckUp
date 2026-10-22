import { existsSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

import * as ort from 'onnxruntime-web';
import { describe, expect, it } from 'vitest';

import diseaseInfo from '../data/disease_info.json';
import { classifyImage } from './classify';
import { createImage } from './imageProcessing';
import { parseLabels } from './labels';
import { validateBackgroundModel, validateClassifier } from './modelValidation';
import { createModels } from './ortModels';

const modelsDir = new URL('../../public/models/', import.meta.url);
const classifierPath = fileURLToPath(new URL('plant_disease_model.onnx', modelsDir));
const backgroundPath = fileURLToPath(new URL('background_removal.onnx', modelsDir));
const labels = parseLabels(readFileSync(new URL('../data/labels.txt', import.meta.url), 'utf8'));

describe.skipIf(!existsSync(classifierPath))('inference with the local models', () => {
  it('classifies a generated leaf image', { timeout: 60_000 }, async () => {
    ort.env.wasm.numThreads = 1;
    const background = await ort.InferenceSession.create(readFileSync(backgroundPath));
    const classifier = await ort.InferenceSession.create(readFileSync(classifierPath));
    validateBackgroundModel(background.inputMetadata, background.outputMetadata);
    validateClassifier(classifier.inputMetadata, classifier.outputMetadata);

    // A green ellipse on a grey background.
    const image = createImage(160, 120);
    for (let y = 0; y < 120; y++) {
      for (let x = 0; x < 160; x++) {
        const inside = ((x - 80) / 60) ** 2 + ((y - 60) / 40) ** 2 < 1;
        image.data.set(inside ? [40, 150, 50, 255] : [128, 128, 128, 255], (y * 160 + x) * 4);
      }
    }

    const result = await classifyImage(image, createModels(ort, background, classifier, labels.length), labels, diseaseInfo);
    expect(result.predictions).toHaveLength(labels.length);
    const total = result.predictions.reduce((sum, prediction) => sum + prediction.confidence, 0);
    expect(total).toBeCloseTo(1, 3);
    expect(labels).toContain(result.predictions[0]!.label);
  });
});
