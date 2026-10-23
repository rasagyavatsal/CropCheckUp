import { readFileSync } from 'node:fs';

import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

// Release Please bumps package.json in each release pull request.
const { version } = JSON.parse(readFileSync(new URL('package.json', import.meta.url), 'utf8')) as { version: string };

export default defineConfig({
  plugins: [react()],
  define: { __APP_VERSION__: JSON.stringify(version) },
  base: './',
  optimizeDeps: { exclude: ['onnxruntime-web'] },
  worker: { format: 'es' },
  test: { environment: 'node' },
});
