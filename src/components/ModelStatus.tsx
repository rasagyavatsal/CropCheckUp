import type { ModelState } from '../useModels';

function megabytes(bytes: number): string {
  return `${(bytes / 1_000_000).toFixed(0)} MB`;
}

export function ModelStatus({ state, onClassifierFile }: { state: ModelState; onClassifierFile(file: File): void }) {
  switch (state.status) {
    case 'ready':
      return null;
    case 'loading': {
      const percent = state.total > 0 ? Math.round((state.loaded / state.total) * 100) : undefined;
      return (
        <div className="notice" role="status">
          <p>
            {state.loaded === 0
              ? 'Loading models…'
              : `Downloading the classifier: ${megabytes(state.loaded)}${state.total ? ` of ${megabytes(state.total)}` : ''}`}
          </p>
          <progress max={100} value={percent} aria-label="Model download progress" />
        </div>
      );
    }
    case 'missing':
      return (
        <div className="notice notice-warning" role="alert">
          <p>
            The classifier model, <code>plant_disease_model.onnx</code>, is not hosted with this app. Choose a copy from a
            training run to load it in this tab, or place it in <code>public/models/</code> and reload.
          </p>
          <label className="button">
            Choose model file
            <input
              type="file"
              accept=".onnx"
              hidden
              onChange={(event) => {
                const file = event.target.files?.[0];
                if (file) onClassifierFile(file);
              }}
            />
          </label>
        </div>
      );
    case 'error':
      return (
        <div className="notice notice-error" role="alert">
          <p>The models could not be loaded: {state.message}</p>
        </div>
      );
  }
}
