import tensorflow as tf
from tensorflow.keras import layers, models, optimizers, callbacks
from tensorflow.keras.applications.mobilenet_v3 import preprocess_input
import os
import zipfile

# --- T4 GPU OPTIMIZATIONS ---
# Mixed Precision: Uses FP16 on T4 Tensor Cores for ~2-3× speedup
# while keeping numerically sensitive ops in FP32 automatically.
tf.keras.mixed_precision.set_global_policy('mixed_float16')
print(f"Compute dtype: {tf.keras.mixed_precision.global_policy().compute_dtype}")
print(f"Variable dtype: {tf.keras.mixed_precision.global_policy().variable_dtype}")

# Verify GPU is available
gpus = tf.config.list_physical_devices('GPU')
print(f"GPUs available: {gpus}")
if gpus:
    # Prevent TF from allocating all GPU memory upfront
    for gpu in gpus:
        tf.config.experimental.set_memory_growth(gpu, True)

# 1. Google Colab Setup
try:
    # --- HIGH-SPEED DATA ACCESS ---
    ZIP_PATH = '/content/plantvillage.zip'
    LOCAL_DATA_PATH = '/content/plant_data' 
    
    if not os.path.exists(LOCAL_DATA_PATH):
        print(f"Unzipping {ZIP_PATH} to local storage...")
        with zipfile.ZipFile(ZIP_PATH, 'r') as zip_ref:
            zip_ref.extractall(LOCAL_DATA_PATH)
        print("Unzip complete.")
        
        # --- ROBUST CLEANUP & FOLDER DISCOVERY ---
        print("Cleaning up and discovering dataset structure...")
        actual_data_dir = LOCAL_DATA_PATH
        
        # 1. Delete the pesky __MACOSX folder if it exists
        macosx_path = os.path.join(LOCAL_DATA_PATH, '__MACOSX')
        if os.path.exists(macosx_path):
            import shutil
            shutil.rmtree(macosx_path)
            print("Removed __MACOSX metadata folder.")

        # 2. Find the folder that actually contains subdirectories (the classes)
        # Sometimes zipping creates a nested structure: plant_data/plantvillage/Apple...
        for root, dirs, files in os.walk(LOCAL_DATA_PATH):
            if len(dirs) >= 30: # Look for the folder with many sub-folders (classes)
                actual_data_dir = root
                break
        
        DATASET_PATH = actual_data_dir
        print(f"Corrected DATASET_PATH to: {DATASET_PATH}")

        # 3. Final cleanup of any stray non-image files
        valid_extensions = ('.jpg', '.jpeg', '.png', '.bmp')
        for root, dirs, files in os.walk(DATASET_PATH):
            for file in files:
                if not file.lower().endswith(valid_extensions):
                    os.remove(os.path.join(root, file))
    else:
        # If folder already exists, we still need to find the correct nested path
        for root, dirs, files in os.walk(LOCAL_DATA_PATH):
            if len(dirs) >= 30:
                DATASET_PATH = root
                break
        print(f"Using existing dataset at: {DATASET_PATH}")
    
except ImportError:
    print("Not running in Google Colab. Using local 'plantvillage/' directory.")
    DATASET_PATH = 'plantvillage/'

# 2. Output Configuration
OUTPUT_DIR = '/content/plant_disease_outputs'
os.makedirs(OUTPUT_DIR, exist_ok=True)

IMG_SIZE = (224, 224)
BATCH_SIZE = 64   # Good GPU utilization; RAM issues were from cache/XLA, not batch size
NUM_CLASSES = 38 

# 3. Data Augmentation — runs ON GPU as part of the training model's forward pass.
#    NOT part of the inference/export model, so TFLite stays clean.
#    Previously this ran on CPU via tf.data.map(), which starved the GPU
#    (Colab T4 only has 2 CPU cores).
data_augmentation = models.Sequential([
    layers.RandomFlip("horizontal_and_vertical"),
    layers.RandomRotation(0.2, fill_mode='constant', fill_value=0.0),
    layers.RandomZoom(0.2, fill_mode='constant', fill_value=0.0),
    layers.RandomContrast(0.2),
], name='augmentation')

def build_model(num_classes):
    # 4. Load Pretrained MobileNetV3 (Small)
    base_model = tf.keras.applications.MobileNetV3Small(
        input_shape=(*IMG_SIZE, 3),
        include_top=False,
        weights='imagenet',
        pooling='avg'
    )

    # 5. Freeze the base model (Initial Transfer Learning phase)
    base_model.trainable = False

    # 6. Build the Classification Head.
    #    The preprocessing Lambda normalises [0, 255] → [-1, 1] using
    #    MobileNetV3's official preprocess_input.  This layer IS part of the
    #    exported TFLite graph, so the Dart client only needs to feed raw
    #    [0, 255] uint8-range values.
    model = models.Sequential([
        layers.Input(shape=(*IMG_SIZE, 3)),
        layers.Lambda(preprocess_input, name='mobilenet_preprocessing'),
        base_model,
        layers.Dropout(0.2),
        layers.Dense(num_classes, dtype='float32'),  # Force FP32 for numerically stable softmax
        layers.Activation('softmax', dtype='float32')
    ])

    return model

if __name__ == "__main__":
    # Load Training and Validation Data from the FAST local directory
    train_ds = tf.keras.utils.image_dataset_from_directory(
        DATASET_PATH,
        validation_split=0.2,
        subset="training",
        seed=123,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE
    )

    val_ds = tf.keras.utils.image_dataset_from_directory(
        DATASET_PATH,
        validation_split=0.2,
        subset="validation",
        seed=123,
        image_size=IMG_SIZE,
        batch_size=BATCH_SIZE
    )

    # --- SAVE AUTHORITATIVE LABEL ORDER ---
    # class_names is the alphabetical directory order that Keras assigns to
    # integer indices.  The mobile app MUST use this exact list.
    class_names = train_ds.class_names
    labels_path = os.path.join(OUTPUT_DIR, 'labels.txt')
    with open(labels_path, 'w') as f:
        f.write('\n'.join(class_names) + '\n')
    print(f"Saved {len(class_names)} labels to {labels_path}")
    print(f"Label order: {class_names}")

    # --- HIGH-PERFORMANCE DATA PIPELINE ---
    # Augmentation is now inside the training model (runs on GPU),
    # so the data pipeline only needs to read and shuffle — CPU can easily keep up.
    train_ds = train_ds.shuffle(buffer_size=50)
    train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)
    val_ds = val_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

    # --- BUILD MODELS ---
    # `model` = clean inference model (for TFLite export, no augmentation)
    # `train_model` = wraps `model` with GPU-accelerated augmentation
    model = build_model(NUM_CLASSES)

    # Wrap with augmentation using Functional API — augmentation runs on GPU
    # during training, and `model` stays clean for export. Weights are SHARED.
    train_inputs = tf.keras.Input(shape=(*IMG_SIZE, 3))
    x = data_augmentation(train_inputs)
    train_outputs = model(x)
    train_model = tf.keras.Model(train_inputs, train_outputs, name='train_model')

    train_model.compile(
        optimizer=optimizers.Adam(learning_rate=0.001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )

    # --- TRAINING CALLBACKS ---
    training_callbacks = [
        callbacks.EarlyStopping(
            monitor='val_loss',
            patience=3,
            restore_best_weights=True,
            verbose=1
        ),
        callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=2,
            min_lr=1e-6,
            verbose=1
        ),
    ]

    # 7. Initial Training (Training only the new classification head)
    print("Starting initial training (Top Layers)...")
    train_model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=10,
        callbacks=training_callbacks
    )

    # 8. Fine-Tuning (Unfreeze the base model)
    print("Starting fine-tuning (All Layers)...")
    # The base_model is layer index 1 inside the inner `model` Sequential:
    # [Lambda(preprocessing), BaseModel, Dropout, Dense, Activation]
    model.layers[1].trainable = True 
    
    train_model.compile(
        optimizer=optimizers.Adam(learning_rate=0.0001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    train_model.fit(
        train_ds,
        validation_data=val_ds,
        epochs=10,
        callbacks=training_callbacks
    )

    # 9. Save Final Keras Model to Drive
    keras_path = os.path.join(OUTPUT_DIR, 'plant_disease_model.h5')
    model.save(keras_path)
    print(f"Keras model saved to {keras_path}")

    # 10. Export to TFLite for Mobile Deployment (Saved to Drive)
    #     The training model uses mixed_float16 which injects float16 ops
    #     (e.g. Rescaling's tf.Mul) that TFLite cannot convert.
    #     Solution: rebuild a clean float32 model and copy trained weights.
    print("Building float32 model for TFLite export...")
    tf.keras.mixed_precision.set_global_policy('float32')
    export_model = build_model(NUM_CLASSES)
    export_model.set_weights(model.get_weights())

    converter = tf.lite.TFLiteConverter.from_keras_model(export_model)
    tflite_model = converter.convert()
    tflite_path = os.path.join(OUTPUT_DIR, 'plant_disease_model.tflite')
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"TFLite model saved to {tflite_path}")

