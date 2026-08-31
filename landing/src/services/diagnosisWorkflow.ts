import { DiagnosisResult } from '../models/diagnosisResult';
import { BackgroundRemovalService } from './backgroundRemoval';
import {
  canvasToDataUrl,
  cropResizeSquare,
  decodeImage,
  resizeToMaxDimension,
} from './imageProcessing';
import { PlantClassifier } from './plantClassifier';
import type { ProcessedImage } from '../types/diagnosis';

/** Coordinates browser decoding, segmentation, resizing, and inference. */
export class DiagnosisWorkflow {
  private readonly backgroundRemoval = new BackgroundRemovalService();
  private readonly classifier = new PlantClassifier();
  private initializationPromise: Promise<void> | undefined;

  async initialize(): Promise<void> {
    if (!this.initializationPromise) {
      this.initializationPromise = Promise.all([
        this.backgroundRemoval.initialize(),
        this.classifier.initialize(),
      ]).then(() => undefined).catch((error: unknown) => {
        this.initializationPromise = undefined;
        throw error;
      });
    }
    await this.initializationPromise;
  }

  async processFile(file: File): Promise<ProcessedImage> {
    const sourceImage = await decodeImage(file);
    const sourceCanvas = resizeToMaxDimension(sourceImage);
    const segmentedCanvas = await this.backgroundRemoval.removeBackground(sourceCanvas);
    const modelCanvas = cropResizeSquare(segmentedCanvas);

    return {
      canvas: modelCanvas,
      dataUrl: canvasToDataUrl(modelCanvas),
    };
  }

  classifyImage(processedImage: ProcessedImage): Promise<DiagnosisResult | null> {
    return this.classifier.classifyImage(processedImage.canvas);
  }
}
