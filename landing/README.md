# CropCheckUp Landing Site

This directory contains the source code for the public-facing static landing site for the CropCheckUp project.

## Purpose

The landing site serves as the primary informational page for the CropCheckUp application. It provides an overview of the project, how it works, limitations, and links to the dataset, Kaggle notebook, and GitHub repository. It acts as the public frontend matching the repository's mixed-license, non-commercial model/dataset status.

## Requirements

- Node.js `>=22.12.0`

## Setup

Install dependencies using:

```sh
npm ci
```

## Development

Start the local development server:

```sh
npm run dev
```

## Validation

Before committing, run the following commands to ensure code quality and build success:

```sh
npm run check
npm run build
npm run lint
```

## Source Layout

- `src/components/` - Reusable Astro and UI components.
- `src/layouts/` - Page layouts.
- `src/pages/` - Application routes and pages.
- `src/styles/` - Global CSS and styling.
- `public/` - Static assets like images and icons.
- `tests/` - Playwright end-to-end tests.

## Deployment

This site is built using [Astro](https://astro.build). The output is a static site (`npm run build`) which can be deployed to any static hosting provider (e.g., GitHub Pages, Vercel, Netlify).

## Project Links

For more details on the main project, please refer to:

- [Main README](../README.md)
- [Model Card](../MODEL_CARD.md)
- [Dataset License](../DATASET_LICENSE.md)
- [Attribution](../ATTRIBUTION.md)
