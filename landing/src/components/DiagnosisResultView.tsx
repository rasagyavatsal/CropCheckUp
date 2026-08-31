import { DiagnosisResult } from '../models/diagnosisResult';
import type { ReactNode } from 'react';
import { Icon } from './Icon';

type DiagnosisResultViewProps = {
  result: DiagnosisResult;
  imageDataUrl?: string;
  onStartOver: () => void;
};

const healthyTips = [
  'Maintain proper spacing between plants.',
  'Use drip irrigation rather than overhead watering.',
  'Rotate crops each season.',
  'Monitor periodically for early signs of disease.',
];

export function DiagnosisResultView({
  result,
  imageDataUrl,
  onStartOver,
}: DiagnosisResultViewProps) {
  const statusColorClass = result.isHealthy ? 'is-healthy' : 'is-diseased';

  return (
    <div className="diagnosis-result-view">
      <article className={`diagnosis-summary ${statusColorClass}`}>
        <div className="diagnosis-summary-topline">
          <span className="status-badge">
            <Icon name={result.isHealthy ? 'check' : 'ban'} size={18} />
            {result.isHealthy ? 'Healthy plant' : 'Disease detected'}
          </span>
          <Icon name={result.isHealthy ? 'check' : 'info'} size={24} />
        </div>
        <h3>{result.diseaseName}</h3>
        <div className="diagnosis-data-grid">
          <div>
            <span className="diagnosis-data-label">Crop</span>
            <strong>{result.cropName}</strong>
          </div>
          <div>
            <span className="diagnosis-data-label">Confidence</span>
            <strong>{result.confidencePercent}%</strong>
          </div>
        </div>
        <p className="diagnosis-raw-label">Raw label: <code>{result.rawLabel}</code></p>
        <ConfidenceMeter confidence={result.confidence} />
        <div className="diagnosis-callout">
          <Icon name={result.isHealthy ? 'target' : 'info'} size={20} />
          <span>
            {result.isHealthy
              ? 'Monitor crop health during routine field checks.'
              : 'Inspect affected plants before selecting treatment.'}
          </span>
        </div>
      </article>

      {imageDataUrl && (
        <figure className="evidence-image-card">
          <img src={imageDataUrl} alt={`Processed leaf used to diagnose ${result.cropName}`} />
          <figcaption>Processed leaf preview · 224 × 224 model input</figcaption>
        </figure>
      )}

      {result.isHealthy ? (
        <>
          <InfoSection title="Status" icon="info">
            <p>
              The model classified this {result.cropName} leaf as healthy with {result.confidencePercent}% confidence. Keep monitoring new growth and changing spots.
            </p>
          </InfoSection>
          <InfoSection title="Maintenance Tips" icon="check">
            <BulletList items={healthyTips} />
          </InfoSection>
        </>
      ) : (
        <>
          {result.symptoms && <InfoSection title="Symptoms" icon="target"><ResultContent content={result.symptoms} /></InfoSection>}
          {result.causes && <InfoSection title="Causes" icon="brain"><ResultContent content={result.causes} /></InfoSection>}
          {result.management && <InfoSection title="Management & Treatment" icon="bulb"><ResultContent content={result.management} /></InfoSection>}
          {!result.symptoms && !result.causes && !result.management && (
            <InfoSection title="About" icon="info">
              <p>
                {result.diseaseName} was detected on the {result.cropName} leaf with {result.confidencePercent}% confidence. Use this as triage and inspect the plant before treatment.
              </p>
            </InfoSection>
          )}
        </>
      )}

      <button className="btn btn-outline result-reset-button" type="button" onClick={onStartOver}>
        <Icon name="image" size={18} />
        Check another leaf
      </button>
    </div>
  );
}

function ConfidenceMeter({ confidence }: { confidence: number }) {
  const percentage = Math.round(confidence * 100);
  const colorClass = percentage >= 80 ? 'high' : percentage >= 50 ? 'medium' : 'low';

  return (
    <div className="confidence-meter" aria-label={`Diagnosis confidence score: ${percentage}%`}>
      <div className="confidence-meter-labels">
        <span>Confidence score</span>
        <strong className={colorClass}>{percentage}%</strong>
      </div>
      <div className="confidence-track" role="progressbar" aria-valuemin={0} aria-valuemax={100} aria-valuenow={percentage}>
        <span className={colorClass} style={{ width: `${Math.max(0, Math.min(100, percentage))}%` }} />
      </div>
    </div>
  );
}

function InfoSection({
  title,
  icon,
  children,
}: {
  title: string;
  icon: 'brain' | 'bulb' | 'check' | 'info' | 'target';
  children: ReactNode;
}) {
  return (
    <section className="diagnosis-info-section">
      <div className="diagnosis-info-heading">
        <span><Icon name={icon} size={18} /></span>
        <h4>{title}</h4>
      </div>
      {children}
    </section>
  );
}

function ResultContent({ content }: { content: string }) {
  const items = content.split('\n').map((item) => item.trim()).filter(Boolean);
  return items.length > 1 ? <BulletList items={items} /> : <p>{content}</p>;
}

function BulletList({ items }: { items: string[] }) {
  return (
    <ul className="diagnosis-bullet-list">
      {items.map((item) => <li key={item}>{item}</li>)}
    </ul>
  );
}
