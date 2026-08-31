import { useEffect, useState } from 'react';

import { Icon } from './Icon';

function persistTheme(isDark: boolean): void {
  try {
    localStorage.setItem('color-theme', isDark ? 'dark' : 'light');
  } catch {
    // Private browsing modes can disable localStorage. The current page still updates.
  }
}

export function ThemeToggle() {
  const [isDark, setIsDark] = useState<boolean>(false);

  useEffect(() => {
    setIsDark(document.documentElement.classList.contains('dark'));
  }, []);

  const handleToggle = (): void => {
    const nextIsDark = !isDark;
    document.documentElement.classList.toggle('dark', nextIsDark);
    persistTheme(nextIsDark);
    setIsDark(nextIsDark);
  };

  return (
    <button
      id="theme-toggle"
      className="btn btn-outline icon-btn"
      type="button"
      aria-label="Toggle theme"
      aria-pressed={isDark}
      onClick={handleToggle}
    >
      <Icon
        id="theme-toggle-light-icon"
        name="sun"
        size={20}
        className={isDark ? undefined : 'hidden'}
      />
      <Icon
        id="theme-toggle-dark-icon"
        name="moon"
        size={20}
        className={isDark ? 'hidden' : undefined}
      />
    </button>
  );
}
