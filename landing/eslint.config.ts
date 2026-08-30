import type { Linter } from 'eslint';
import tsEslintPlugin from '@typescript-eslint/eslint-plugin';
import eslintPluginAstro from 'eslint-plugin-astro';
import globals from 'globals';

const tsFiles = ['**/*.{ts,mts,cts}'];
const tsRecommendedConfig = tsEslintPlugin.configs['flat/recommended'] as unknown as Linter.Config[];
const tsRecommended: Linter.Config[] = tsRecommendedConfig.map((config) => ({
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
