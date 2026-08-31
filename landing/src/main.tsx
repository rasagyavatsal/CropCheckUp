import { StrictMode } from 'react';
import { hydrateRoot } from 'react-dom/client';

import { App } from './App';
import { initializeTheme } from './theme';
import './styles/global.css';
import './styles/components.css';

initializeTheme();

const rootElement = document.getElementById('root');

if (!rootElement) {
  throw new Error('The React root element is missing.');
}

hydrateRoot(rootElement,
  <StrictMode>
    <App />
  </StrictMode>,
);
