# CropCheckUp: Flutter Implementation Guide

This guide provides a step-by-step technical blueprint for building a high-performance, offline-capable mobile application using your trained `plant_disease_model.tflite`.

---

## 1. Project Initialization

### Create the Flutter Project
Run the following command inside your dedicated folder:
```bash
flutter create --project-name crop_check_up .
```

### Add Assets
1. Create an `assets` folder in your project root.
2. Move your `plant_disease_model.tflite` and `labels.txt` into this folder.
3. Register them in your `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/plant_disease_model.tflite
    - assets/labels.txt
```

---

## 2. Dependencies

Add these essential packages to your `pubspec.yaml`:
- **`tflite_flutter`**: For high-speed on-device inference.
- **`camera`**: To access the device's camera for live detection.
- **`image`**: For resizing and preprocessing images to the required 224x224 format.
- **`path_provider`**: For managing local file paths.

---

## 3. Core AI Engine (The "Classifier")

Create a `classifier.dart` file to handle the model logic. This class should implement three primary functions:

### A. Model Loading
Use the `Interpreter` class from `tflite_flutter` to load your model from assets. Load the `labels.txt` into a `List<String>` simultaneously.

### B. Image Preprocessing
Before passing an image to the model, you must:
1. **Resize**: Convert the camera frame to exactly **224x224** pixels.
2. **Normalize**: Since the model was trained with MobileNetV3 (standard weights), ensure your pixel values are in the range expected by the model (typically `[0, 255]` for Keras V3 implementations).
3. **Tensor Conversion**: Convert the image into a 4D array (Shape: `[1, 224, 224, 3]`).

### C. Inference & Interpretation
1. Run the interpreter on the input tensor.
2. The output will be a list of 38 probability scores.
3. Find the index with the highest score.
4. Map that index to your `labels.txt` to get the disease name.

---

## 4. User Interface (UI) Design

### The Viewfinder (Camera Screen)
- Use a **CameraPreview** widget to show the live feed.
- **Overlay**: Add a semi-transparent overlay with a "Target Box" in the center to guide the user to center the leaf.

### The Diagnosis Bottom Sheet
When a diagnosis is ready, slide up a bottom sheet containing:
- **Primary Label**: The name of the detected disease (e.g., "Tomato - Late Blight").
- **Confidence Bar**: A progress bar showing the AI's certainty (e.g., 94%).
- **Status Icon**: Use Green for "Healthy" and Red/Yellow for "Diseased" classes.
- **Treatment Button**: A button that opens a detailed info page about the specific disease.

---

## 5. Optimization for the Field (Farmers)

### Offline-First Architecture
Ensure **zero** internet calls are made during the diagnosis process. All logic must reside within the TFLite interpreter.

### Lighting & Focus
- Add a **Flash Toggle** button on the camera UI for low-light conditions.
- Implement **Auto-Focus** listeners to ensure the leaf texture is sharp before capturing.

### Performance (Approach B)
To ensure the app feels "instant":
- Run inference in a **Background Isolate** (Thread). This prevents the camera preview from "stuttering" while the AI is calculating.
- Set a threshold (e.g., 75%). Only show the diagnosis if the model is very sure; otherwise, prompt the user to "Move closer" or "Improve lighting."

---

## 6. Testing Strategy

1. **Validation**: Test the app against the 20% validation images from your original dataset.
2. **Environmental Testing**: Test under direct sunlight, overcast sky, and artificial light to ensure the **Approach B (Augmentation)** training holds up.
3. **Latency Check**: Ensure the time from "Click" to "Diagnosis" is under **500ms** on mid-range Android devices.

---

## Final Deliverables Check
- [ ] `plant_disease_model.tflite` in assets.
- [ ] `labels.txt` mapping 38 classes.
- [ ] Flutter UI with live camera feed.
- [ ] Instant offline diagnosis logic.
