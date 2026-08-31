import { useEffect, useRef, useState, type ChangeEvent, type RefObject } from 'react';

import packageJson from '../../package.json';
import { DiagnosisResultView } from './DiagnosisResultView';
import { Icon } from './Icon';
import { DiagnosisResult } from '../models/diagnosisResult';
import { DiagnosisHistoryRepository } from '../services/diagnosisHistoryRepository';
import { DiagnosisWorkflow } from '../services/diagnosisWorkflow';
import type { DiagnosisHistoryEntryData, ProcessedImage } from '../types/diagnosis';

const ACCEPTED_IMAGE_TYPES = 'image/png,image/jpeg,image/webp';
const ACCEPTED_IMAGE_TYPE_SET = new Set(ACCEPTED_IMAGE_TYPES.split(','));
const MAX_UPLOAD_BYTES = 20 * 1024 * 1024;

type Screen = 'upload' | 'processing' | 'preview' | 'result';
type ModelStatus = 'loading' | 'ready' | 'error';

type ActiveResult = {
  result: DiagnosisResult;
  imageDataUrl: string;
};

/** The website's upload-only diagnosis experience. */
export function DiagnosisWorkspace() {
  const workflow = useRef(new DiagnosisWorkflow()).current;
  const historyRepository = useRef(new DiagnosisHistoryRepository()).current;
  const fileInput = useRef<HTMLInputElement>(null);
  const requestId = useRef(0);
  const [screen, setScreen] = useState<Screen>('upload');
  const [modelStatus, setModelStatus] = useState<ModelStatus>('loading');
  const [processingStep, setProcessingStep] = useState('Loading local diagnosis models…');
  const [processedImage, setProcessedImage] = useState<ProcessedImage | null>(null);
  const [activeResult, setActiveResult] = useState<ActiveResult | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [history, setHistory] = useState<DiagnosisHistoryEntryData[]>([]);
  const [historyLoading, setHistoryLoading] = useState(true);
  const [historyError, setHistoryError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;
    void workflow.initialize()
      .then(() => {
        if (isMounted) {
          setModelStatus('ready');
          setProcessingStep('Ready for a leaf photo.');
        }
      })
      .catch((reason: unknown) => {
        if (isMounted) {
          setModelStatus('error');
          setError(`Diagnosis models could not be loaded. ${errorMessage(reason)}`);
        }
      });

    void loadHistory(isMounted);
    return () => {
      isMounted = false;
    };
  }, [workflow]);

  async function loadHistory(isMounted = true): Promise<void> {
    setHistoryLoading(true);
    setHistoryError(null);
    try {
      const entries = await historyRepository.loadRecent(10);
      if (isMounted) {
        setHistory(entries);
      }
    } catch {
      if (isMounted) {
        setHistoryError('Recent diagnoses could not be loaded.');
      }
    } finally {
      if (isMounted) {
        setHistoryLoading(false);
      }
    }
  }

  async function handleFileChange(event: ChangeEvent<HTMLInputElement>): Promise<void> {
    const file = event.target.files?.[0];
    event.target.value = '';
    if (!file) {
      return;
    }

    if (!isSupportedImage(file)) {
      setError('Choose a PNG, JPEG, or WebP image.');
      return;
    }
    if (file.size > MAX_UPLOAD_BYTES) {
      setError('Choose an image smaller than 20 MB.');
      return;
    }

    const currentRequest = ++requestId.current;
    setScreen('processing');
    setProcessingStep('Preparing your leaf photo…');
    setError(null);
    setActiveResult(null);

    let initialized = false;
    try {
      await workflow.initialize();
      initialized = true;
      if (currentRequest !== requestId.current) {
        return;
      }
      setModelStatus('ready');
      setProcessingStep('Removing the background…');
      const nextImage = await workflow.processFile(file);
      if (currentRequest !== requestId.current) {
        return;
      }
      setProcessedImage(nextImage);
      setProcessingStep('Review the processed leaf before diagnosis.');
      setScreen('preview');
    } catch (reason: unknown) {
      if (currentRequest !== requestId.current) {
        return;
      }
      setModelStatus(initialized ? 'ready' : 'error');
      setScreen('upload');
      setError(`This image could not be processed. ${errorMessage(reason)}`);
    }
  }

  async function handleConfirm(): Promise<void> {
    if (!processedImage || screen !== 'preview') {
      return;
    }

    const currentRequest = ++requestId.current;
    setScreen('processing');
    setProcessingStep('Running the TensorFlow Lite classifier…');
    setError(null);

    try {
      const result = await workflow.classifyImage(processedImage);
      if (currentRequest !== requestId.current) {
        return;
      }
      if (!result) {
        throw new Error('The model did not return a confident label.');
      }

      const nextResult = { result, imageDataUrl: processedImage.dataUrl };
      setActiveResult(nextResult);
      setScreen('result');
      try {
        await historyRepository.recordDiagnosis(result, processedImage.dataUrl);
        void loadHistory();
      } catch {
        setHistoryError('The diagnosis is ready, but it could not be saved to history.');
      }
    } catch (reason: unknown) {
      if (currentRequest !== requestId.current) {
        return;
      }
      setScreen('preview');
      setError(`Could not confidently diagnose this image. ${errorMessage(reason)}`);
    }
  }

  function handleStartOver(): void {
    requestId.current += 1;
    setScreen('upload');
    setProcessedImage(null);
    setActiveResult(null);
    setError(null);
    setProcessingStep('Ready for a leaf photo.');
  }

  function handleRetryModels(): void {
    setError(null);
    setModelStatus('loading');
    setProcessingStep('Loading local diagnosis models…');
    void workflow.initialize()
      .then(() => {
        setModelStatus('ready');
        setProcessingStep('Ready for a leaf photo.');
      })
      .catch((reason: unknown) => {
        setModelStatus('error');
        setError(`Diagnosis models could not be loaded. ${errorMessage(reason)}`);
      });
  }

  function handleHistoryEntry(entry: DiagnosisHistoryEntryData): void {
    try {
      setActiveResult({
        result: DiagnosisResult.fromJSON(entry.result),
        imageDataUrl: entry.imageDataUrl,
      });
      setScreen('result');
      setError(null);
    } catch {
      setHistoryError('This saved diagnosis is no longer readable.');
    }
  }

  const isBusy = screen === 'processing';
  const canUpload = modelStatus === 'ready' && !isBusy;

  return (
    <section id="diagnose" className="diagnosis-section section">
      <div className="container">
        <div className="diagnosis-section-heading">
          <div>
            <p className="eyebrow">Browser diagnosis</p>
            <h2>Check a <span className="text-highlight">leaf</span></h2>
            <p className="section-subtitle">
              Upload one clear leaf photo. Segmentation, preprocessing, and TensorFlow Lite inference run locally in this browser.
            </p>
          </div>
          <div className={`model-status model-status-${modelStatus}`} role="status">
            <span className="model-status-dot" />
            {modelStatus === 'ready' ? 'Models ready' : modelStatus === 'loading' ? 'Loading models' : 'Models unavailable'}
          </div>
        </div>

        <div className="diagnosis-layout">
          <div className="diagnosis-panel glass-panel" aria-busy={isBusy}>
            {screen === 'upload' && (
              <UploadState
                fileInput={fileInput}
                canUpload={canUpload}
                onFileChange={handleFileChange}
                onRetryModels={handleRetryModels}
                modelStatus={modelStatus}
              />
            )}
            {screen === 'processing' && <ProcessingState message={processingStep} />}
            {screen === 'preview' && processedImage && (
              <PreviewState
                imageDataUrl={processedImage.dataUrl}
                onConfirm={handleConfirm}
                onRetry={handleStartOver}
              />
            )}
            {screen === 'result' && activeResult && (
              <DiagnosisResultView
                result={activeResult.result}
                imageDataUrl={activeResult.imageDataUrl}
                onStartOver={handleStartOver}
              />
            )}
            {error && <p className="diagnosis-error" role="alert">{error}</p>}
          </div>

          <aside className="diagnosis-contract glass-panel">
            <div className="diagnosis-contract-icon"><Icon name="bulb" size={28} /></div>
            <p className="eyebrow">Private by design</p>
            <h3>Everything stays in your browser.</h3>
            <p>
              The uploaded image is decoded, segmented, resized to 224 × 224, and classified locally. Nothing is sent to an API.
            </p>
            <dl>
              <div><dt>68</dt><dd>crop and condition labels</dd></div>
              <div><dt>224</dt><dd>pixel model input</dd></div>
              <div><dt>20</dt><dd>history entries retained</dd></div>
            </dl>
            <small>Website v{packageJson.version}</small>
          </aside>
        </div>

        <RecentDiagnoses
          entries={history}
          isLoading={historyLoading}
          error={historyError}
          onRetry={() => void loadHistory()}
          onEntryTap={handleHistoryEntry}
        />
      </div>
    </section>
  );
}

function UploadState({
  fileInput,
  canUpload,
  onFileChange,
  onRetryModels,
  modelStatus,
}: {
  fileInput: RefObject<HTMLInputElement | null>;
  canUpload: boolean;
  onFileChange: (event: ChangeEvent<HTMLInputElement>) => void;
  onRetryModels: () => void;
  modelStatus: ModelStatus;
}) {
  return (
    <div className="upload-state">
      <label className={`upload-dropzone${canUpload ? '' : ' is-disabled'}`} htmlFor="leaf-upload">
        <input
          ref={fileInput}
          id="leaf-upload"
          type="file"
          accept={ACCEPTED_IMAGE_TYPES}
          onChange={onFileChange}
          disabled={!canUpload}
        />
        <span className="upload-icon"><Icon name="image" size={36} /></span>
        <strong>{modelStatus === 'loading' ? 'Preparing diagnosis models…' : 'Choose a leaf photo'}</strong>
        <span>PNG, JPEG, or WebP · one clear leaf works best</span>
        <span className="btn btn-primary upload-button">Choose photo</span>
      </label>
      {modelStatus === 'error' && (
        <button className="btn btn-outline" type="button" onClick={onRetryModels}>Retry model loading</button>
      )}
      <p className="upload-help">For the most reliable result, use a focused image with good light and minimal clutter.</p>
    </div>
  );
}

function ProcessingState({ message }: { message: string }) {
  return (
    <div className="processing-state" role="status" aria-live="polite">
      <span className="processing-spinner" />
      <h3>Working on your leaf</h3>
      <p>{message}</p>
      <div className="processing-steps" aria-hidden="true">
        <span className="is-active">Segment</span>
        <span>Resize</span>
        <span>Classify</span>
      </div>
    </div>
  );
}

function PreviewState({
  imageDataUrl,
  onConfirm,
  onRetry,
}: {
  imageDataUrl: string;
  onConfirm: () => void;
  onRetry: () => void;
}) {
  return (
    <div className="preview-state">
      <div className="preview-heading">
        <div>
          <p className="eyebrow">Step 1 of 2</p>
          <h3>Review the processed leaf</h3>
        </div>
        <span className="preview-ready"><Icon name="check" size={16} /> Model ready</span>
      </div>
      <figure className="preview-image-panel">
        <img src={imageDataUrl} alt="Segmented leaf preview" />
        <figcaption>Background removed · 224 × 224 RGB input</figcaption>
      </figure>
      <p className="preview-instruction">Make sure the leaf is clear before diagnosing.</p>
      <div className="preview-actions">
        <button className="btn btn-primary" type="button" onClick={onConfirm}><Icon name="check" size={18} /> Diagnose</button>
        <button className="btn btn-outline" type="button" onClick={onRetry}><Icon name="image" size={18} /> Choose another photo</button>
      </div>
    </div>
  );
}

function RecentDiagnoses({
  entries,
  isLoading,
  error,
  onRetry,
  onEntryTap,
}: {
  entries: DiagnosisHistoryEntryData[];
  isLoading: boolean;
  error: string | null;
  onRetry: () => void;
  onEntryTap: (entry: DiagnosisHistoryEntryData) => void;
}) {
  return (
    <section className="recent-diagnoses" aria-labelledby="recent-diagnoses-title">
      <div className="recent-diagnoses-heading">
        <div>
          <p className="eyebrow">Saved locally</p>
          <h3 id="recent-diagnoses-title">Recent diagnoses</h3>
        </div>
        <span>Latest 10 of 20 retained</span>
      </div>
      {isLoading && <div className="history-message"><span className="small-spinner" /> Loading recent diagnoses</div>}
      {!isLoading && error && (
        <div className="history-message history-error" role="alert">
          <span>{error}</span>
          <button className="btn btn-outline" type="button" onClick={onRetry}>Retry</button>
        </div>
      )}
      {!isLoading && !error && entries.length === 0 && (
        <div className="history-message"><Icon name="image" size={24} /><span><strong>No diagnoses yet.</strong> Complete a diagnosis and it will appear here.</span></div>
      )}
      {!isLoading && !error && entries.length > 0 && (
        <div className="history-grid">
          {entries.map((entry) => <HistoryCard key={entry.id} entry={entry} onTap={() => onEntryTap(entry)} />)}
        </div>
      )}
    </section>
  );
}

function HistoryCard({ entry, onTap }: { entry: DiagnosisHistoryEntryData; onTap: () => void }) {
  const result = DiagnosisResult.fromJSON(entry.result);
  const statusClass = result.isHealthy ? 'is-healthy' : 'is-diseased';
  return (
    <button className={`history-card ${statusClass}`} type="button" onClick={onTap} aria-label={`Open diagnosis for ${result.cropName}, ${result.diseaseName}`}>
      <span className="history-card-image"><img src={entry.imageDataUrl} alt="" /></span>
      <span className="history-card-content">
        <strong>{result.cropName}</strong>
        <span>{result.diseaseName}</span>
        <small>{formatShortDate(entry.createdAt)} · {result.confidencePercent}% confidence</small>
      </span>
      <Icon name="check" size={18} />
    </button>
  );
}

function formatShortDate(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return 'Saved diagnosis';
  }
  return new Intl.DateTimeFormat(undefined, {
    month: 'short',
    day: 'numeric',
    year: date.getFullYear() === new Date().getFullYear() ? undefined : 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
}

function isSupportedImage(file: File): boolean {
  return ACCEPTED_IMAGE_TYPE_SET.has(file.type) || /\.(png|jpe?g|webp)$/i.test(file.name);
}

function errorMessage(reason: unknown): string {
  return reason instanceof Error ? reason.message : String(reason);
}
