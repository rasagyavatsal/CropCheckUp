import tsEslintPlugin from '@typescript-eslint/eslint-plugin';
import eslintPluginAstro from 'eslint-plugin-astro';
import globals from 'globals';

const tsFiles = ['**/*.{ts,mts,cts}'];
const tsRecommended = tsEslintPlugin.configs['flat/recommended'].map((config) => ({
  ...config,
  files: config.files ?? tsFiles,
}));

export default [
  {
    ignores: [
      '.astro/**',
      'dist/**',
      'node_modules/**',
      'playwright-report/**',
      'test-results/**',
    ],
  },
  ...eslintPluginAstro.configs.recommended,
  ...tsRecommended,
  {
    files: tsFiles,
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
      },
    },
  },
];
