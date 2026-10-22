import { readFileSync } from 'node:fs';

import { describe, expect, it } from 'vitest';

import diseaseInfo from '../data/disease_info.json';
import { humanize, labelParts, makePrediction, parseLabels, rankPredictions } from './labels';

const labelsText = readFileSync(new URL('../data/labels.txt', import.meta.url), 'utf8');

describe('labelParts', () => {
  it('splits crop and condition', () => {
    expect(labelParts('Corn_(maize)___Common_rust_')).toEqual({ crop: 'Corn (maize)', condition: 'Common rust' });
  });

  it('normalises healthy labels', () => {
    expect(labelParts('Apple___healthy')).toEqual({ crop: 'Apple', condition: 'Healthy' });
  });

  it('marks labels without a separator as unknown', () => {
    expect(labelParts('Mystery_leaf')).toEqual({ crop: 'Mystery leaf', condition: 'Unknown' });
  });

  it('collapses whitespace', () => {
    expect(humanize('Spider_mites Two-spotted_spider_mite')).toBe('Spider mites Two-spotted spider mite');
  });
});

describe('parseLabels', () => {
  it('reads the bundled labels', () => {
    const labels = parseLabels(labelsText);
    expect(labels).toHaveLength(38);
    expect(labels[0]).toBe('Apple___Apple_scab');
  });

  it('rejects the wrong number of labels', () => {
    expect(() => parseLabels('A___b\nC___d\n')).toThrow('contains 2 labels; expected 38');
  });

  it('keys disease information by known labels', () => {
    const labels = parseLabels(labelsText);
    for (const key of Object.keys(diseaseInfo)) {
      expect(labels).toContain(key);
    }
  });
});

describe('makePrediction', () => {
  it('copies only non-empty information', () => {
    const prediction = makePrediction('Tomato___Late_blight', 0.9, { symptoms: 'Spots', causes: ' ', management: 'Spray' });
    expect(prediction).toEqual({
      label: 'Tomato___Late_blight',
      crop: 'Tomato',
      condition: 'Late blight',
      confidence: 0.9,
      symptoms: 'Spots',
      management: 'Spray',
    });
  });
});

describe('rankPredictions', () => {
  const labels = ['A___x', 'B___y', 'C___healthy'];

  it('orders by score and keeps the top k', () => {
    const ranked = rankPredictions([0.2, 0.7, 0.1], labels, {}, 2);
    expect(ranked.map((prediction) => prediction.label)).toEqual(['B___y', 'A___x']);
  });

  it('rejects mismatched score counts', () => {
    expect(() => rankPredictions([1, 0], labels, {}, 1)).toThrow('returned 2 scores; expected 3');
  });

  it('rejects non-finite scores', () => {
    expect(() => rankPredictions([0.5, Number.NaN, 0.5], labels, {}, 1)).toThrow('non-finite');
  });
});
