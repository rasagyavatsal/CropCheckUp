export type Theme = 'light' | 'dark';

const themeStorageKey = 'color-theme';

export function getInitialTheme(): Theme {
  if (typeof window === 'undefined') {
    return 'light';
  }

  try {
    const storedTheme = window.localStorage.getItem(themeStorageKey);
    if (storedTheme === 'dark') {
      return 'dark';
    }
    if (storedTheme !== null) {
      return 'light';
    }
  } catch {
    // Continue with the system preference when localStorage is unavailable.
  }

  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

export function applyTheme(theme: Theme): void {
  document.documentElement.classList.toggle('dark', theme === 'dark');
}

export function initializeTheme(): void {
  if (typeof document !== 'undefined') {
    applyTheme(getInitialTheme());
  }
}
