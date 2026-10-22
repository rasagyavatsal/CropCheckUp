import type { ClassificationResult } from '../lib/classify';

export interface ModelUrls {
  backgroundModel: string;
  classifier: string;
}

export type WorkerRequest =
  | { id: number; type: 'load'; urls: ModelUrls }
  | { id: number; type: 'load-classifier-file'; data: ArrayBuffer }
  | { id: number; type: 'classify'; image: Blob };

export type WorkerResponse =
  | { id: number; type: 'progress'; loaded: number; total: number }
  | { id: number; type: 'loaded' }
  | { id: number; type: 'result'; result: ClassificationResult }
  | { id: number; type: 'error'; message: string; missingClassifier?: boolean };
