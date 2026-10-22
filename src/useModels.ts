import { useCallback, useEffect, useState } from 'react';

import { InferenceClient, InferenceError } from './lib/inferenceClient';

export type ModelState =
  | { status: 'loading'; loaded: number; total: number }
  | { status: 'ready' }
  | { status: 'missing' }
  | { status: 'error'; message: string };

let client: InferenceClient | undefined;

/** The shared inference worker, created on first use. */
export function getClient(): InferenceClient {
  client ??= new InferenceClient();
  return client;
}

function modelUrl(name: string): string {
  return new URL(`models/${name}`, document.baseURI).href;
}

function failure(error: unknown): ModelState {
  if (error instanceof InferenceError && error.missingClassifier) {
    return { status: 'missing' };
  }
  return { status: 'error', message: error instanceof Error ? error.message : String(error) };
}

/** Load both models on mount, with a fallback for choosing the classifier file by hand. */
export function useModels(): { state: ModelState; loadClassifierFile(file: File): void } {
  const [state, setState] = useState<ModelState>({ status: 'loading', loaded: 0, total: 0 });

  useEffect(() => {
    let active = true;
    getClient()
      .load(
        { backgroundModel: modelUrl('background_removal.onnx'), classifier: modelUrl('plant_disease_model.onnx') },
        (loaded, total) => active && setState({ status: 'loading', loaded, total }),
      )
      .then(
        () => active && setState({ status: 'ready' }),
        (error: unknown) => active && setState(failure(error)),
      );
    return () => {
      active = false;
    };
  }, []);

  const loadClassifierFile = useCallback((file: File) => {
    setState({ status: 'loading', loaded: 0, total: 0 });
    getClient()
      .loadClassifierFile(file)
      .then(
        () => setState({ status: 'ready' }),
        (error: unknown) => setState(failure(error)),
      );
  }, []);

  return { state, loadClassifierFile };
}
