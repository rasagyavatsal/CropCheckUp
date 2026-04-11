"""
Unit tests for model.py — validates architecture, layer composition,
and the separation of augmentation from the exported model.
"""
import os
import sys
import unittest

import numpy as np

# Ensure the project root is on the path so 'model' is importable.
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import tensorflow as tf
from model import build_model, data_augmentation, IMG_SIZE, NUM_CLASSES


class TestBuildModel(unittest.TestCase):
    """Validates that build_model produces a correct, inference-safe model."""

    @classmethod
    def setUpClass(cls):
        cls.model = build_model(NUM_CLASSES)

    def test_output_shape(self):
        """Model output must be (batch, NUM_CLASSES)."""
        self.assertEqual(self.model.output_shape, (None, NUM_CLASSES))

    def test_input_shape(self):
        """Model must accept (batch, 224, 224, 3) inputs."""
        expected = (None, *IMG_SIZE, 3)
        self.assertEqual(self.model.input_shape, expected)

    def test_no_augmentation_layers_in_model(self):
        """Data augmentation layers must NOT be part of the exported model.

        The old bug baked RandomFlip / GaussianNoise into the TFLite graph,
        corrupting every inference. Verify they are absent.
        """
        augmentation_layer_types = {
            'RandomFlip',
            'RandomRotation',
            'RandomZoom',
            'RandomContrast',
            'GaussianNoise',
        }
        for layer in self.model.layers:
            self.assertNotIn(
                type(layer).__name__,
                augmentation_layer_types,
                f'Augmentation layer {type(layer).__name__} found in model — '
                f'it must only be applied in the training data pipeline.',
            )

    def test_has_preprocessing_layer(self):
        """Model must contain a Lambda preprocessing layer that normalises
        inputs from [0, 255] to [-1, 1] via MobileNetV3's preprocess_input.
        """
        lambda_layers = [
            layer for layer in self.model.layers
            if isinstance(layer, tf.keras.layers.Lambda)
        ]
        self.assertTrue(
            len(lambda_layers) >= 1,
            'Model must contain a Lambda preprocessing layer.',
        )

    def test_preprocessing_normalises_to_minus1_plus1(self):
        """Feed a [0, 255] tensor through the preprocessing Lambda and verify
        the output is in approximately [-1, 1] range.
        """
        # Create a dummy input with known pixel values.
        dummy = np.array([[[[0.0, 127.5, 255.0]]]])  # shape (1,1,1,3)
        # Extract the Lambda layer (first real layer)
        lambda_layer = None
        for layer in self.model.layers:
            if isinstance(layer, tf.keras.layers.Lambda):
                lambda_layer = layer
                break
        self.assertIsNotNone(lambda_layer)

        result = lambda_layer(dummy).numpy()
        # preprocess_input maps 0→-1, 127.5→0, 255→1
        np.testing.assert_allclose(result[0, 0, 0, 0], -1.0, atol=0.05)
        np.testing.assert_allclose(result[0, 0, 0, 1], 0.0, atol=0.05)
        np.testing.assert_allclose(result[0, 0, 0, 2], 1.0, atol=0.05)

    def test_softmax_output(self):
        """Output probabilities must sum to ~1 for any input."""
        dummy = np.random.randint(0, 256, (1, *IMG_SIZE, 3)).astype('float32')
        preds = self.model.predict(dummy, verbose=0)
        self.assertAlmostEqual(float(np.sum(preds)), 1.0, places=4)

    def test_output_num_classes(self):
        """Output dimension must equal NUM_CLASSES."""
        dummy = np.random.randint(0, 256, (1, *IMG_SIZE, 3)).astype('float32')
        preds = self.model.predict(dummy, verbose=0)
        self.assertEqual(preds.shape[-1], NUM_CLASSES)


class TestDataAugmentation(unittest.TestCase):
    """Validates the standalone data_augmentation pipeline."""

    def test_augmentation_is_separate_sequential(self):
        """data_augmentation must be a standalone Sequential model,
        not embedded inside build_model's graph.
        """
        self.assertIsInstance(data_augmentation, tf.keras.Sequential)

    def test_augmentation_contains_noise(self):
        """GaussianNoise must exist in the augmentation pipeline."""
        types = [type(l).__name__ for l in data_augmentation.layers]
        self.assertIn('GaussianNoise', types)

    def test_augmentation_training_flag(self):
        """Augmentation must be callable with training=True (used in
        train_ds.map) and training=False (should be identity).
        """
        dummy = np.random.randint(0, 256, (1, *IMG_SIZE, 3)).astype('float32')
        # Should not raise
        _ = data_augmentation(dummy, training=True)
        result_off = data_augmentation(dummy, training=False)
        # With training=False, RandomFlip/Noise should be no-ops,
        # so output ≈ input (within float tolerance).
        np.testing.assert_allclose(result_off.numpy(), dummy, atol=1.0)


if __name__ == '__main__':
    unittest.main()
