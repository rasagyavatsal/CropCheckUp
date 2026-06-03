# Contributing to CropCheckUp

First off, thank you for considering contributing to CropCheckUp!

## Setup Project Prerequisites
- **FVM** (Flutter Version Management)
- **Flutter**: `3.41.6`
- **Node**: `>=22.12.0`

## Flutter Setup
To set up the Flutter project, run:
```sh
fvm flutter pub get
```

## Flutter Validation Commands
Before submitting changes, make sure your code passes validation:
```sh
fvm flutter analyze
fvm flutter doctor
fvm flutter test
```

## Landing Setup
To set up the landing page project, navigate to the `landing` directory and install dependencies:
```sh
cd landing && npm ci
```

## Landing Validation Commands
Before submitting changes to the landing page, make sure your code passes validation:
```sh
npm run check
npm run build
npm run lint
```

## Important Note on Data and Models
Changes touching model/data documentation must preserve the non-commercial CC BY-NC-SA 4.0 wording.
