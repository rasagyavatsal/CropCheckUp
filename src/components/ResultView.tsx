import { useState } from 'react';

import type { ClassificationResult } from '../lib/classify';
import type { Prediction } from '../lib/labels';

const TOP_K_OPTIONS = [3, 5, 10];

function percent(confidence: number): string {
  return `${(confidence * 100).toFixed(1)}%`;
}

function Confidence({ value }: { value: number }) {
  return (
    <div className="confidence">
      <div className="confidence-track">
        <div className="confidence-fill" style={{ width: `${Math.max(value * 100, 0.5)}%` }} />
      </div>
      <span className="confidence-value">{percent(value)}</span>
    </div>
  );
}

const DETAILS = [
  ['symptoms', 'Symptoms'],
  ['causes', 'Causes'],
  ['management', 'Management'],
] as const;

function Details({ prediction }: { prediction: Prediction }) {
  const sections = DETAILS.filter(([key]) => prediction[key]);
  if (sections.length === 0) return null;
  return (
    <dl className="details">
      {sections.map(([key, title]) => (
        <div key={key}>
          <dt>{title}</dt>
          <dd>{prediction[key]}</dd>
        </div>
      ))}
    </dl>
  );
}

function summary(result: ClassificationResult, fileName: string, topK: number) {
  const [prediction, ...alternatives] = result.predictions.slice(0, topK);
  return {
    image: fileName,
    prediction,
    alternatives,
    backgroundRemoved: result.backgroundRemoved,
    foregroundFraction: Number(result.foregroundFraction.toFixed(4)),
  };
}

export function ResultView({ result, fileName }: { result: ClassificationResult; fileName: string }) {
  const [topK, setTopK] = useState(3);
  const [copied, setCopied] = useState(false);
  const [top, ...rest] = result.predictions;
  const alternatives = rest.slice(0, topK - 1);
  if (!top) return null;

  const copy = () => {
    void navigator.clipboard.writeText(JSON.stringify(summary(result, fileName, topK), null, 2)).then(() => {
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    });
  };

  return (
    <section className="result" aria-live="polite">
      <p className="eyebrow">{top.crop}</p>
      <h2 className={top.condition === 'Healthy' ? 'healthy' : undefined}>{top.condition}</h2>
      <Confidence value={top.confidence} />
      <Details prediction={top} />

      <div className="alternatives-header">
        <h3>Other possibilities</h3>
        <label>
          Show{' '}
          <select value={topK} onChange={(event) => setTopK(Number(event.target.value))}>
            {TOP_K_OPTIONS.map((k) => (
              <option key={k} value={k}>
                top {k}
              </option>
            ))}
          </select>
        </label>
      </div>
      <ol className="alternatives">
        {alternatives.map((prediction) => (
          <li key={prediction.label}>
            <span>
              {prediction.crop} · <strong>{prediction.condition}</strong>
            </span>
            <Confidence value={prediction.confidence} />
          </li>
        ))}
      </ol>
      <button type="button" className="link-button" onClick={copy}>
        {copied ? 'Copied' : 'Copy as JSON'}
      </button>
    </section>
  );
}
