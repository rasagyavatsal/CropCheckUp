import { useCallback, useEffect, useState } from 'react';

import { ImagePicker } from './components/ImagePicker';
import { ModelStatus } from './components/ModelStatus';
import { ProcessedPreview } from './components/ProcessedPreview';
import { ResultView } from './components/ResultView';
import type { ClassificationResult } from './lib/classify';
import { getClient, useModels } from './useModels';

interface Photo {
  file: File;
  url: string;
}

type Analysis =
  | { status: 'idle' }
  | { status: 'running' }
  | { status: 'done'; result: ClassificationResult }
  | { status: 'error'; message: string };

export function App() {
  const models = useModels();
  const [photo, setPhoto] = useState<Photo>();
  const [analysis, setAnalysis] = useState<Analysis>({ status: 'idle' });
  const ready = models.state.status === 'ready';

  const choose = useCallback((file: File) => {
    setPhoto((previous) => {
      if (previous) URL.revokeObjectURL(previous.url);
      return { file, url: URL.createObjectURL(file) };
    });
  }, []);

  useEffect(() => {
    if (!photo || !ready) return;
    let active = true;
    setAnalysis({ status: 'running' });
    getClient()
      .classify(photo.file)
      .then(
        (result) => active && setAnalysis({ status: 'done', result }),
        (error: unknown) => active && setAnalysis({ status: 'error', message: error instanceof Error ? error.message : String(error) }),
      );
    return () => {
      active = false;
    };
  }, [photo, ready]);

  return (
    <div className="page">
      <header className="header">
        <img src="./favicon.svg" alt="" width={36} height={36} />
        <div>
          <h1>CropCheckUp</h1>
          <p>Identify crop-leaf diseases from a photo. Everything runs in your browser; images are never uploaded.</p>
        </div>
      </header>

      <ModelStatus state={models.state} onClassifierFile={models.loadClassifierFile} />

      <main className={photo ? 'workspace' : undefined}>
        {photo && (
          <div className="photos">
            <figure className="photo" key={photo.url}>
              <img src={photo.url} alt="Selected leaf" />
              <figcaption>{photo.file.name}</figcaption>
            </figure>
            {analysis.status === 'done' && (
              <>
                <ProcessedPreview image={analysis.result.processed} fileName={photo.file.name} />
                <p className="note">
                  {analysis.result.backgroundRemoved
                    ? 'Background removed and replaced with black, as in training.'
                    : `Background removal kept only ${Math.round(analysis.result.foregroundFraction * 100)}% of the photo, so the whole photo was classified.`}
                </p>
              </>
            )}
          </div>
        )}

        <div className="panel">
          {analysis.status === 'running' && (
            <section className="result" role="status">
              <p className="status">
                <span className="spinner" aria-hidden="true" /> Analysing the leaf…
              </p>
              <div className="skeleton" aria-hidden="true">
                <span />
                <span />
                <span />
              </div>
            </section>
          )}
          {photo && analysis.status === 'idle' && !ready && <p className="status">Waiting for the models…</p>}
          {analysis.status === 'error' && (
            <p className="notice notice-error" role="alert">
              Could not classify this image: {analysis.message}
            </p>
          )}
          {analysis.status === 'done' && photo && <ResultView result={analysis.result} fileName={photo.file.name} />}
          <ImagePicker onImage={choose} compact={Boolean(photo)} />
        </div>
      </main>

      <footer className="footer">
        <p>
          The classifier covers 38 conditions across 14 crops and was trained on PlantVillage photos taken against plain
          backgrounds. Accuracy on field photos is lower; confirm a diagnosis with a local agronomist before treating
          crops.
        </p>
        <p>
          <a href="https://github.com/rasagyavatsal/CropCheckUp">Source on GitHub</a>
        </p>
      </footer>
    </div>
  );
}
