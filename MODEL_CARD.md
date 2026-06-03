# Model Card

## Model Details
- **Model Name:** CropCheckUp plant disease classifier
- **Model Format:** TensorFlow Lite
- **Model Asset Path:** `assets/plant_disease_model.tflite`
- **Label Path:** `assets/labels.txt`
- **Disease Information Path:** `assets/disease_info.json`
- **App Version:** `1.0.0+1`
- **Input Size:** 224x224 RGB image
- **Output:** Top predicted class label and confidence
- **Current Label Count:** 68 labels

## Supported Crop Groups
Apple, Blueberry, Bottle_Gourd, Cherry_(including_sour), Corn_(maize), Grape, Mango, Orange, Papaya, Peach, Pepper,_bell, Potato, Raspberry, Soybean, Squash, Strawberry, Tomato, Zucchini.

## Inference Pipeline
Camera/gallery image -> background removal with `image_background_remover` -> square resize to 224x224 -> TensorFlow Lite classifier -> disease information lookup.

## Data Sources
CropCheckUp dataset, PlantVillage Dataset, Mango Leaf Disease Dataset, with links to `ATTRIBUTION.md`.

## Intended Use
Educational, research, and non-commercial AI-assisted leaf disease screening.

## Out of Scope Use / Not Intended For
Professional diagnosis, pesticide decisions without expert confirmation, unsupported crops/diseases, commercial deployment of the bundled model.

## Limitations
Image quality, lighting, blur, multiple leaves/plants, unsupported classes, lookalike symptoms, nutrient/water/pest stress mapping to nearest trained label.

## Safety Disclaimer
Not professional agricultural advice; users should consult an agricultural expert before treatment decisions.
