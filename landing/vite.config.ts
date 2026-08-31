import { createElement } from 'react';
import { renderToString } from 'react-dom/server';
import { defineConfig, type Plugin } from 'vite';
import react from '@vitejs/plugin-react';

import { App } from './src/App';

const prerenderReactApp = (): Plugin => ({
  name: 'prerender-react-app',
  transformIndexHtml(html) {
    return html.replace(
      '<div id="root"><!-- React renders the landing page here. --></div>',
      `<div id="root">${renderToString(createElement(App))}</div>`,
    );
  },
});

export default defineConfig({
  plugins: [react(), prerenderReactApp()],
  preview: {
    port: 4321,
  },
  server: {
    port: 4321,
  },
});
