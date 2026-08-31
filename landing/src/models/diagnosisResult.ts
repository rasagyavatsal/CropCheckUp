import type { DiagnosisResultData, DiseaseInfo } from '../types/diagnosis';

/** Immutable, display-ready representation of one prediction. */
export class DiagnosisResult {
  readonly rawLabel: string;
  readonly confidence: number;
  readonly symptoms: string | null;
  readonly causes: string | null;
  readonly management: string | null;

  constructor(data: DiagnosisResultData) {
    this.rawLabel = data.rawLabel;
    this.confidence = data.confidence;
    this.symptoms = data.symptoms;
    this.causes = data.causes;
    this.management = data.management;
  }

  get cropName(): string {
    return humanize(this.rawLabel.split('___')[0] ?? '');
  }

  get diseaseName(): string {
    const parts = this.rawLabel.split('___');
    if (parts.length < 2) {
      return 'Unknown';
    }

    const disease = parts[1] ?? '';
    return disease.toLowerCase() === 'healthy' ? 'Healthy' : humanize(disease);
  }

  get displayLabel(): string {
    return `${this.cropName} — ${this.diseaseName}`;
  }

  get isHealthy(): boolean {
    return this.rawLabel.toLowerCase().includes('healthy');
  }

  get confidencePercent(): number {
    return Math.round(this.confidence * 100);
  }

  toJSON(): DiagnosisResultData {
    return {
      rawLabel: this.rawLabel,
      confidence: this.confidence,
      symptoms: this.symptoms,
      causes: this.causes,
      management: this.management,
    };
  }

  static fromJSON(value: unknown): DiagnosisResult {
    if (!isRecord(value) || typeof value.rawLabel !== 'string' || value.rawLabel.length === 0 || typeof value.confidence !== 'number' || !Number.isFinite(value.confidence)) {
      throw new TypeError('Invalid diagnosis result.');
    }

    return new DiagnosisResult({
      rawLabel: value.rawLabel,
      confidence: value.confidence,
      symptoms: optionalString(value.symptoms),
      causes: optionalString(value.causes),
      management: optionalString(value.management),
    });
  }

  static fromPrediction(rawLabel: string, confidence: number, info?: DiseaseInfo): DiagnosisResult {
    return new DiagnosisResult({
      rawLabel,
      confidence,
      symptoms: info?.symptoms ?? null,
      causes: info?.causes ?? null,
      management: info?.management ?? null,
    });
  }
}

export function humanize(segment: string): string {
  return segment.replaceAll('_', ' ').replace(/ {2,}/g, ' ').trim();
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}

function optionalString(value: unknown): string | null {
  return typeof value === 'string' && value.length > 0 ? value : null;
}
