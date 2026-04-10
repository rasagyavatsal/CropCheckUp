import tensorflow as tf
from tensorflow.keras import layers, models, optimizers
import os
import zipfile

# 1. Google Colab & Drive Setup
try:
    from google.colab import drive
    drive.mount('/content/drive')
    
    # --- HIGH-SPEED DATA ACCESS ---
    ZIP_PATH = '/content/drive/MyDrive/plantvillage.zip'
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

# 2. Output Configuration (Still saved to Drive for persistence)
OUTPUT_DIR = '/content/drive/MyDrive/plant_disease_outputs'
os.makedirs(OUTPUT_DIR, exist_ok=True)

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
NUM_CLASSES = 38 

# 3. Data Augmentation (Approach B: Synthetic Background Simulation)
data_augmentation = models.Sequential([
    layers.RandomFlip("horizontal_and_vertical"),
    layers.RandomRotation(0.2),
    layers.RandomZoom(0.2),
    layers.RandomContrast(0.2),
    layers.GaussianNoise(0.1), 
])

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

    # 6. Build the Classification Head
    model = models.Sequential([
        layers.Input(shape=(*IMG_SIZE, 3)),
        data_augmentation,
        base_model,
        layers.Dropout(0.2),
        layers.Dense(num_classes, activation='softmax')
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

    # Optimize data loading performance
    train_ds = train_ds.prefetch(buffer_size=tf.data.AUTOTUNE)
    val_ds = val_ds.prefetch(buffer_size=tf.data.AUTOTUNE)

    # Instantiate and compile the model
    model = build_model(NUM_CLASSES)
    model.compile(
        optimizer=optimizers.Adam(learning_rate=0.001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )

    # 7. Initial Training (Training only the new classification head)
    print("Starting initial training (Top Layers)...")
    model.fit(train_ds, validation_data=val_ds, epochs=10)

    # 8. Fine-Tuning (Unfreeze the base model)
    print("Starting fine-tuning (All Layers)...")
    # In our Sequential model: [Input, Augmentation, BaseModel, Dropout, Dense]
    # The base_model is at index 1.
    model.layers[1].trainable = True 
    
    model.compile(
        optimizer=optimizers.Adam(learning_rate=0.0001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    model.fit(train_ds, validation_data=val_ds, epochs=10)

    # 9. Save Final Keras Model to Drive
    keras_path = os.path.join(OUTPUT_DIR, 'plant_disease_model.h5')
    model.save(keras_path)
    print(f"Keras model saved to {keras_path}")

    # 10. Export to TFLite for Mobile Deployment (Saved to Drive)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    tflite_path = os.path.join(OUTPUT_DIR, 'plant_disease_model.tflite')
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    
    print(f"TFLite model saved to {tflite_path}")


