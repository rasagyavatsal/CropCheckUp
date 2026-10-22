export const EXPECTED_LABEL_COUNT = 38;

export interface DiseaseInfo {
  name?: string;
  symptoms?: string;
  causes?: string;
  management?: string;
}

export interface Prediction {
  label: string;
  crop: string;
  condition: string;
  confidence: number;
  symptoms?: string;
  causes?: string;
  management?: string;
}

/** Convert a model label segment into a readable name. */
export function humanize(value: string): string {
  return value.replaceAll('_', ' ').split(/\s+/).filter(Boolean).join(' ');
}

/** Return the crop and condition names encoded in a model label. */
export function labelParts(rawLabel: string): { crop: string; condition: string } {
  const separator = rawLabel.indexOf('___');
  if (separator === -1) {
    return { crop: humanize(rawLabel), condition: 'Unknown' };
  }
  const condition = rawLabel.slice(separator + 3);
  return {
    crop: humanize(rawLabel.slice(0, separator)),
    condition: condition.toLowerCase() === 'healthy' ? 'Healthy' : humanize(condition),
  };
}

export function parseLabels(text: string): string[] {
  const labels = text.split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
  if (labels.length !== EXPECTED_LABEL_COUNT) {
    throw new Error(`labels.txt contains ${labels.length} labels; expected ${EXPECTED_LABEL_COUNT}`);
  }
  return labels;
}

export function makePrediction(rawLabel: string, confidence: number, info?: DiseaseInfo): Prediction {
  const prediction: Prediction = { label: rawLabel, ...labelParts(rawLabel), confidence };
  for (const key of ['symptoms', 'causes', 'management'] as const) {
    const value = info?.[key];
    if (typeof value === 'string' && value.trim()) {
      prediction[key] = value;
    }
  }
  return prediction;
}

/** Return the `topK` highest-scoring predictions, best first. */
export function rankPredictions(
  scores: ArrayLike<number>,
  labels: readonly string[],
  diseaseInfo: Readonly<Record<string, DiseaseInfo>>,
  topK: number,
): Prediction[] {
  if (scores.length !== labels.length) {
    throw new Error(`the classifier returned ${scores.length} scores; expected ${labels.length}`);
  }
  const indices = Array.from(labels, (_, index) => index);
  for (const index of indices) {
    if (!Number.isFinite(scores[index])) {
      throw new Error('the classifier returned a non-finite score');
    }
  }
  return indices
    .sort((a, b) => scores[b]! - scores[a]!)
    .slice(0, Math.max(1, topK))
    .map((index) => makePrediction(labels[index]!, scores[index]!, diseaseInfo[labels[index]!]));
}
