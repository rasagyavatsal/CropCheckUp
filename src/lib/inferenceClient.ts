import type { ModelUrls, WorkerRequest, WorkerResponse } from '../worker/protocol';
import type { ClassificationResult } from './classify';

type Request = WorkerRequest extends infer R ? (R extends { id: number } ? Omit<R, 'id'> : never) : never;

export class InferenceError extends Error {
  constructor(
    message: string,
    readonly missingClassifier = false,
  ) {
    super(message);
  }
}

interface Pending {
  resolve(response: WorkerResponse): void;
  reject(error: InferenceError): void;
  onProgress?: (loaded: number, total: number) => void;
}

/** Promise-based access to the inference worker. */
export class InferenceClient {
  private readonly worker = new Worker(new URL('../worker/inference.worker.ts', import.meta.url), { type: 'module' });
  private readonly pending = new Map<number, Pending>();
  private nextId = 0;
  private loading: Promise<void> | undefined;
  private readonly progressListeners = new Set<(loaded: number, total: number) => void>();

  constructor() {
    this.worker.onmessage = (event: MessageEvent<WorkerResponse>) => {
      const response = event.data;
      const pending = this.pending.get(response.id);
      if (!pending) return;
      if (response.type === 'progress') {
        pending.onProgress?.(response.loaded, response.total);
        return;
      }
      this.pending.delete(response.id);
      if (response.type === 'error') {
        pending.reject(new InferenceError(response.message, response.missingClassifier));
      } else {
        pending.resolve(response);
      }
    };
    this.worker.onerror = (event) => {
      const error = new InferenceError(`the inference worker failed: ${event.message}`);
      for (const pending of this.pending.values()) pending.reject(error);
      this.pending.clear();
    };
  }

  private send(request: Request, transfer: Transferable[] = [], onProgress?: Pending['onProgress']): Promise<WorkerResponse> {
    const id = this.nextId++;
    return new Promise((resolve, reject) => {
      this.pending.set(id, { resolve, reject, onProgress });
      this.worker.postMessage({ ...request, id }, transfer);
    });
  }

  /** Load both models once; concurrent callers share the same download. */
  load(urls: ModelUrls, onProgress?: (loaded: number, total: number) => void): Promise<void> {
    if (onProgress) this.progressListeners.add(onProgress);
    this.loading ??= this.send({ type: 'load', urls }, [], (loaded, total) => {
      for (const listener of this.progressListeners) listener(loaded, total);
    })
      .then(
        () => undefined,
        (error: unknown) => {
          this.loading = undefined;
          throw error;
        },
      )
      .finally(() => this.progressListeners.clear());
    return this.loading;
  }

  async loadClassifierFile(file: Blob): Promise<void> {
    const data = await file.arrayBuffer();
    await this.send({ type: 'load-classifier-file', data }, [data]);
  }

  async classify(image: Blob): Promise<ClassificationResult> {
    const response = await this.send({ type: 'classify', image });
    if (response.type !== 'result') {
      throw new InferenceError(`unexpected worker response: ${response.type}`);
    }
    return response.result;
  }
}
