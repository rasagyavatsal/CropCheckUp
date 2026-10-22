import {
  applyBackgroundMask,
  createBackgroundModelInput,
  createClassifierInput,
  foregroundFraction,
  MIN_FOREGROUND_FRACTION,
  prepareClassifierImage,
  type Mask,
  type RgbaImage,
} from './imageProcessing';
import { rankPredictions, type DiseaseInfo, type Prediction } from './labels';

/** The two ONNX models behind the classifier, abstracted from the runtime that runs them. */
export interface Models {
  /** Return a foreground mask for a normalised 320×320 NCHW tensor. */
  segment(input: Float32Array): Promise<Mask>;
  /** Return one score per label for a 224×224 NHWC tensor of RGB values in [0, 255]. */
  classify(input: Float32Array): Promise<Float32Array>;
}

export interface ClassificationResult {
  /** Every label, best first. */
  predictions: Prediction[];
  /** The exact 224×224 classifier input. */
  processed: RgbaImage;
  /** Whether the background-removal mask was used, or the whole photo was classified instead. */
  backgroundRemoved: boolean;
  foregroundFraction: number;
}

/** Segment, composite, resize and classify an oriented RGBA photo. */
export async function classifyImage(
  source: RgbaImage,
  models: Models,
  labels: readonly string[],
  diseaseInfo: Readonly<Record<string, DiseaseInfo>>,
): Promise<ClassificationResult> {
  const mask = await models.segment(createBackgroundModelInput(source));
  const segmented = applyBackgroundMask(source, mask);
  const kept = foregroundFraction(source, segmented);
  // On close-ups the remover often finds no subject and erases the leaf, so classify the whole photo.
  const backgroundRemoved = kept >= MIN_FOREGROUND_FRACTION;
  const processed = prepareClassifierImage(backgroundRemoved ? segmented : source);
  const scores = await models.classify(createClassifierInput(processed));
  return {
    predictions: rankPredictions(scores, labels, diseaseInfo, labels.length),
    processed,
    backgroundRemoved,
    foregroundFraction: kept,
  };
}
