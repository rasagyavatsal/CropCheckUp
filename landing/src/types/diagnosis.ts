/** Detailed advisory information bundled with a model label. */
export interface DiseaseInfo {
  name?: string;
  symptoms?: string;
  causes?: string;
  management?: string;
}

/** The result returned by one classifier invocation. */
export interface DiagnosisResultData {
  rawLabel: string;
  confidence: number;
  symptoms: string | null;
  causes: string | null;
  management: string | null;
}

/** A result plus the processed evidence image retained in browser history. */
export interface DiagnosisHistoryEntryData {
  id: string;
  createdAt: string;
  result: DiagnosisResultData;
  imageDataUrl: string;
}

/** Image prepared for preview and the classifier. */
export interface ProcessedImage {
  canvas: HTMLCanvasElement;
  dataUrl: string;
}
