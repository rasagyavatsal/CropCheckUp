import { DiagnosisResult } from '../models/diagnosisResult';
import type { DiagnosisHistoryEntryData } from '../types/diagnosis';

const DATABASE_NAME = 'cropcheckup';
const DATABASE_VERSION = 1;
const STORE_NAME = 'diagnoses';
const FALLBACK_KEY = 'cropcheckup.history';
const MAX_ENTRIES = 20;

/** Persists recent diagnoses in IndexedDB, with a small localStorage fallback. */
export class DiagnosisHistoryRepository {
  private databasePromise: Promise<IDBDatabase> | undefined;
  private useFallback = typeof indexedDB === 'undefined';

  async loadRecent(limit = 10): Promise<DiagnosisHistoryEntryData[]> {
    try {
      const records = this.useFallback
        ? readFallbackRecords()
        : await this.readIndexedDbRecords();
      return records
        .sort((first, second) => second.createdAt.localeCompare(first.createdAt))
        .slice(0, limit);
    } catch (error) {
      if (!this.useFallback) {
        this.useFallback = true;
        return readFallbackRecords().slice(0, limit);
      }
      throw error;
    }
  }

  async recordDiagnosis(
    result: DiagnosisResult,
    imageDataUrl: string,
  ): Promise<void> {
    const entry: DiagnosisHistoryEntryData = {
      id: createId(),
      createdAt: new Date().toISOString(),
      result: result.toJSON(),
      imageDataUrl,
    };

    try {
      if (this.useFallback) {
        writeFallbackRecord(entry);
      } else {
        await this.writeIndexedDbRecord(entry);
      }
    } catch (error) {
      if (!this.useFallback) {
        this.useFallback = true;
        writeFallbackRecord(entry);
        return;
      }
      throw error;
    }
  }

  private async readIndexedDbRecords(): Promise<DiagnosisHistoryEntryData[]> {
    const database = await this.openDatabase();
    const transaction = database.transaction(STORE_NAME, 'readonly');
    const request = transaction.objectStore(STORE_NAME).getAll();
    const values = await requestToPromise<unknown[]>(request);
    return values.flatMap(parseStoredEntry);
  }

  private async writeIndexedDbRecord(entry: DiagnosisHistoryEntryData): Promise<void> {
    const database = await this.openDatabase();
    await new Promise<void>((resolve, reject) => {
      const transaction = database.transaction(STORE_NAME, 'readwrite');
      const store = transaction.objectStore(STORE_NAME);
      store.put(entry);
      const allRequest = store.getAll();
      allRequest.onsuccess = () => {
        const records = allRequest.result
          .flatMap(parseStoredEntry)
          .sort((first, second) => second.createdAt.localeCompare(first.createdAt));
        records.slice(MAX_ENTRIES).forEach((record) => store.delete(record.id));
      };
      allRequest.onerror = () => reject(allRequest.error ?? new Error('Could not read diagnosis history.'));
      transaction.oncomplete = () => resolve();
      transaction.onerror = () => reject(transaction.error ?? new Error('Could not save diagnosis history.'));
      transaction.onabort = () => reject(transaction.error ?? new Error('Could not save diagnosis history.'));
    });
  }

  private openDatabase(): Promise<IDBDatabase> {
    if (!this.databasePromise) {
      this.databasePromise = new Promise<IDBDatabase>((resolve, reject) => {
        const request = indexedDB.open(DATABASE_NAME, DATABASE_VERSION);
        request.onupgradeneeded = () => {
          if (!request.result.objectStoreNames.contains(STORE_NAME)) {
            request.result.createObjectStore(STORE_NAME, { keyPath: 'id' });
          }
        };
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error ?? new Error('Could not open diagnosis history.'));
      }).catch((error: unknown) => {
        this.databasePromise = undefined;
        throw error;
      });
    }
    return this.databasePromise;
  }
}

function parseStoredEntry(value: unknown): DiagnosisHistoryEntryData[] {
  if (!isRecord(value) || typeof value.id !== 'string' || typeof value.createdAt !== 'string' || typeof value.imageDataUrl !== 'string') {
    return [];
  }
  try {
    const result = DiagnosisResult.fromJSON(value.result);
    return [{
      id: value.id,
      createdAt: value.createdAt,
      result: result.toJSON(),
      imageDataUrl: value.imageDataUrl,
    }];
  } catch {
    return [];
  }
}

function readFallbackRecords(): DiagnosisHistoryEntryData[] {
  try {
    const raw = localStorage.getItem(FALLBACK_KEY);
    if (!raw) {
      return [];
    }
    const value: unknown = JSON.parse(raw);
    return Array.isArray(value) ? value.flatMap(parseStoredEntry) : [];
  } catch {
    return [];
  }
}

function writeFallbackRecord(entry: DiagnosisHistoryEntryData): void {
  const entries = [entry, ...readFallbackRecords()]
    .sort((first, second) => second.createdAt.localeCompare(first.createdAt))
    .slice(0, MAX_ENTRIES);
  localStorage.setItem(FALLBACK_KEY, JSON.stringify(entries));
}

function requestToPromise<T>(request: IDBRequest<T>): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error ?? new Error('IndexedDB request failed.'));
  });
}

function createId(): string {
  const randomId = typeof crypto !== 'undefined' && 'randomUUID' in crypto
    ? crypto.randomUUID()
    : Math.random().toString(36).slice(2, 10);
  return `diag_${Date.now()}_${randomId}`;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null;
}
