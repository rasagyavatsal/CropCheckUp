"""Local ONNX background removal for CropCheckUp input images.

The bundled model was recovered from the historical browser implementation.
This module deliberately imports NumPy, Pillow, and ONNX Runtime lazily so
importing the CLI does not initialize the segmentation runtime by itself.
"""

from __future__ import annotations

from pathlib import Path
from threading import Lock
from typing import Any, Callable

BACKGROUND_MODEL_SIZE = 320
MODEL_INPUT_NAME = "input.1"
MODEL_INPUT_SHAPE = (1, 3, BACKGROUND_MODEL_SIZE, BACKGROUND_MODEL_SIZE)
MEAN = (0.485, 0.456, 0.406)
STD = (0.229, 0.224, 0.225)


class BackgroundRemovalError(RuntimeError):
    """Raised when the background-removal model cannot process an image."""


SessionFactory = Callable[[Path], Any]


class BackgroundRemovalService:
    """Run the background-removal model, loading its session only on demand."""

    def __init__(self, model_path: Path, session_factory: SessionFactory | None = None):
        self.model_path = Path(model_path)
        self._session_factory = session_factory
        self._session: Any | None = None
        self._session_lock = Lock()
        self._input_name = MODEL_INPUT_NAME

    def initialize(self) -> None:
        """Load and validate the ONNX session without processing an image."""
        self._get_session()

    def remove_background(self, image: Any) -> Any:
        """Return an RGBA Pillow image with the model's foreground mask applied."""
        np = _load_numpy()
        session = self._get_session()

        try:
            source = image.convert("RGBA")
            model_input = create_model_input(source, np=np)
        except (AttributeError, OSError, ValueError) as error:
            raise BackgroundRemovalError(f"could not prepare image for background removal: {error}") from error

        try:
            outputs = session.run(None, {self._input_name: model_input})
        except Exception as error:  # ONNX Runtime exposes backend-specific exception types.
            raise BackgroundRemovalError(f"background-removal inference failed: {error}") from error

        mask = _extract_mask(outputs, np=np)
        return apply_background_mask(source, mask, np=np)

    def _get_session(self) -> Any:
        if self._session is None:
            with self._session_lock:
                if self._session is None:
                    self._session = self._create_session()
        return self._session

    def _create_session(self) -> Any:
        if not self.model_path.is_file():
            raise FileNotFoundError(f"background-removal model not found: {self.model_path}")

        if self._session_factory is not None:
            session = self._session_factory(self.model_path)
        else:
            try:
                import onnxruntime as ort
            except ImportError as error:
                raise RuntimeError(
                    "ONNX Runtime is required for background removal; "
                    "install the CLI dependencies with: python -m pip install -r requirements.txt"
                ) from error

            try:
                session = ort.InferenceSession(
                    str(self.model_path),
                    providers=["CPUExecutionProvider"],
                )
            except Exception as error:  # Keep the CLI error actionable across runtimes/platforms.
                raise BackgroundRemovalError(
                    f"could not load background-removal model {self.model_path}: {error}"
                ) from error

        self._validate_session(session)
        return session

    def _validate_session(self, session: Any) -> None:
        try:
            inputs = session.get_inputs()
            outputs = session.get_outputs()
        except AttributeError:
            # A small injected test double may only expose ``run``. Real ONNX
            # Runtime sessions always expose metadata and are validated below.
            return
        except Exception as error:
            raise BackgroundRemovalError(f"could not inspect background-removal model: {error}") from error

        if len(inputs) != 1:
            raise BackgroundRemovalError(
                f"background-removal model exposes {len(inputs)} inputs; expected one"
            )

        input_metadata = inputs[0]
        input_name = getattr(input_metadata, "name", None)
        if input_name != MODEL_INPUT_NAME:
            raise BackgroundRemovalError(
                f"background-removal model input is {input_name!r}; expected {MODEL_INPUT_NAME!r}"
            )
        self._input_name = input_name

        input_shape = _static_shape(getattr(input_metadata, "shape", None))
        if input_shape is not None and input_shape != MODEL_INPUT_SHAPE:
            raise BackgroundRemovalError(
                f"background-removal model input shape is {input_shape}; "
                f"expected {MODEL_INPUT_SHAPE}"
            )

        input_type = getattr(input_metadata, "type", None)
        if input_type is not None and input_type != "tensor(float)":
            raise BackgroundRemovalError(
                f"background-removal model input type is {input_type!r}; expected 'tensor(float)'"
            )

        if not outputs:
            raise BackgroundRemovalError("background-removal model exposes no mask output")

        output_shape = _static_shape(getattr(outputs[0], "shape", None))
        if output_shape is not None and (
            len(output_shape) != 4
            or output_shape[0] != 1
            or output_shape[1] != 1
            or output_shape[2] < 1
            or output_shape[3] < 1
        ):
            raise BackgroundRemovalError(
                f"background-removal mask output shape is {output_shape}; "
                "expected (1, 1, H, W)"
            )

        output_type = getattr(outputs[0], "type", None)
        if output_type is not None and output_type != "tensor(float)":
            raise BackgroundRemovalError(
                f"background-removal mask output type is {output_type!r}; expected 'tensor(float)'"
            )


def create_model_input(image: Any, *, np: Any | None = None) -> Any:
    """Create the normalized NCHW float32 tensor expected by the ONNX model."""
    np = np or _load_numpy()

    try:
        from PIL import Image
    except ImportError as error:
        raise RuntimeError(
            "Pillow is required for background removal; "
            "install the CLI dependencies with: python -m pip install -r requirements.txt"
        ) from error

    resized = image.convert("RGB").resize(
        (BACKGROUND_MODEL_SIZE, BACKGROUND_MODEL_SIZE),
        resample=Image.Resampling.BILINEAR,
    )
    pixels = np.asarray(resized, dtype=np.float32) / 255.0
    mean = np.asarray(MEAN, dtype=np.float32).reshape(1, 1, 3)
    std = np.asarray(STD, dtype=np.float32).reshape(1, 1, 3)
    normalized = (pixels - mean) / std
    return np.ascontiguousarray(np.transpose(normalized, (2, 0, 1))[None, ...], dtype=np.float32)


def apply_background_mask(image: Any, mask: Any, *, np: Any | None = None) -> Any:
    """Apply a model mask and return an RGBA Pillow image.

    The source alpha is multiplied by the new mask alpha so existing
    transparency is preserved instead of being treated as fully opaque.
    """
    np = np or _load_numpy()

    try:
        from PIL import Image
    except ImportError as error:
        raise RuntimeError(
            "Pillow is required for background removal; "
            "install the CLI dependencies with: python -m pip install -r requirements.txt"
        ) from error

    source = image.convert("RGBA")
    rgba = np.array(source, dtype=np.uint8, copy=True)
    if rgba.ndim != 3 or rgba.shape[2] != 4:
        raise BackgroundRemovalError(f"source image has invalid RGBA shape {rgba.shape}")

    mask_array = np.asarray(mask, dtype=np.float32)
    if mask_array.ndim != 2 or mask_array.size == 0:
        raise BackgroundRemovalError(f"background-removal mask has invalid shape {mask_array.shape}")
    if not np.isfinite(mask_array).all():
        raise BackgroundRemovalError("background-removal mask contains non-finite values")
    if float(mask_array.min()) < 0.0 or float(mask_array.max()) > 1.0:
        raise BackgroundRemovalError("background-removal mask values must be between 0 and 1")

    height, width = rgba.shape[:2]
    resized_mask = _resize_mask(mask_array, width, height, np=np)
    enhanced_mask = _enhance_mask_edges(rgba, resized_mask, np=np)
    smoothed_mask = _smooth_mask(enhanced_mask, np=np)

    mask_alpha = np.where(
        smoothed_mask > 0.55,
        255.0,
        np.where(smoothed_mask < 0.45, 0.0, ((smoothed_mask - 0.45) / 0.1) * 255.0),
    )
    mask_alpha = np.clip(np.rint(mask_alpha), 0, 255).astype(np.uint8)
    rgba[:, :, 3] = np.rint(mask_alpha.astype(np.float32) * rgba[:, :, 3] / 255.0).astype(np.uint8)
    return Image.fromarray(rgba)


def remove_background(image: Any, model_path: Path) -> Any:
    """Apply background removal using the cached service for ``model_path``."""
    return get_background_removal_service(model_path).remove_background(image)


_SERVICE_CACHE: dict[Path, BackgroundRemovalService] = {}
_SERVICE_CACHE_LOCK = Lock()


def get_background_removal_service(model_path: Path) -> BackgroundRemovalService:
    """Return one lazily initialized service per model path."""
    key = Path(model_path).expanduser().resolve()
    with _SERVICE_CACHE_LOCK:
        service = _SERVICE_CACHE.get(key)
        if service is None:
            service = BackgroundRemovalService(key)
            _SERVICE_CACHE[key] = service
        return service


def _extract_mask(outputs: Any, *, np: Any) -> Any:
    if outputs is None:
        raise BackgroundRemovalError("background-removal model returned no outputs")

    try:
        first_output = outputs[0]
    except (IndexError, KeyError, TypeError) as error:
        raise BackgroundRemovalError("background-removal model returned no mask output") from error

    try:
        mask = np.asarray(first_output)
    except (TypeError, ValueError, OverflowError) as error:
        raise BackgroundRemovalError(f"background-removal mask output is invalid: {error}") from error
    if mask.dtype.kind != "f":
        raise BackgroundRemovalError(
            f"background-removal mask output has type {mask.dtype}; expected floating-point values"
        )
    mask = np.asarray(mask, dtype=np.float32)
    if mask.ndim == 4 and mask.shape[0] == 1 and mask.shape[1] == 1:
        mask = mask[0, 0]
    elif mask.ndim == 3 and mask.shape[0] == 1:
        mask = mask[0]
    elif mask.ndim != 2:
        raise BackgroundRemovalError(
            f"background-removal mask has shape {mask.shape}; expected (H, W), (1, H, W), or (1, 1, H, W)"
        )

    if mask.size == 0:
        raise BackgroundRemovalError("background-removal mask is empty")
    if not np.isfinite(mask).all():
        raise BackgroundRemovalError("background-removal mask contains non-finite values")
    if float(mask.min()) < 0.0 or float(mask.max()) > 1.0:
        raise BackgroundRemovalError("background-removal mask values must be between 0 and 1")
    return np.ascontiguousarray(mask, dtype=np.float32)


def _resize_mask(mask: Any, width: int, height: int, *, np: Any) -> Any:
    mask_height, mask_width = mask.shape
    if (mask_width, mask_height) == (width, height):
        return mask.copy()

    source_y = np.arange(height, dtype=np.float32) * mask_height / height
    source_x = np.arange(width, dtype=np.float32) * mask_width / width
    y1 = np.floor(source_y).astype(np.intp)
    x1 = np.floor(source_x).astype(np.intp)
    y2 = np.minimum(mask_height - 1, y1 + 1)
    x2 = np.minimum(mask_width - 1, x1 + 1)
    y_weight = source_y - y1
    x_weight = source_x - x1

    top_left = mask[y1[:, None], x1[None, :]]
    top_right = mask[y1[:, None], x2[None, :]]
    bottom_left = mask[y2[:, None], x1[None, :]]
    bottom_right = mask[y2[:, None], x2[None, :]]
    top = top_left * (1.0 - x_weight[None, :]) + top_right * x_weight[None, :]
    bottom = bottom_left * (1.0 - x_weight[None, :]) + bottom_right * x_weight[None, :]
    return top * (1.0 - y_weight[:, None]) + bottom * y_weight[:, None]


def _enhance_mask_edges(rgba: Any, mask: Any, *, np: Any) -> Any:
    enhanced = mask.copy()
    height, width = mask.shape
    if height < 3 or width < 3:
        return enhanced

    pixels = rgba[:, :, :3].astype(np.int16, copy=False)
    gradient_red = np.abs(pixels[1:-1, 2:, 0] - pixels[1:-1, :-2, 0]) + np.abs(
        pixels[2:, 1:-1, 0] - pixels[:-2, 1:-1, 0]
    )
    gradient_green = np.abs(pixels[1:-1, 2:, 1] - pixels[1:-1, :-2, 1]) + np.abs(
        pixels[2:, 1:-1, 1] - pixels[:-2, 1:-1, 1]
    )
    gradient_blue = np.abs(pixels[1:-1, 2:, 2] - pixels[1:-1, :-2, 2]) + np.abs(
        pixels[2:, 1:-1, 2] - pixels[:-2, 1:-1, 2]
    )
    gradient_magnitude = (gradient_red + gradient_green + gradient_blue) / 3.0

    current = mask[1:-1, 1:-1]
    neighborhood = (
        mask[:-2, :-2]
        + mask[:-2, 1:-1]
        + mask[:-2, 2:]
        + mask[1:-1, :-2]
        + mask[1:-1, 1:-1]
        + mask[1:-1, 2:]
        + mask[2:, :-2]
        + mask[2:, 1:-1]
        + mask[2:, 2:]
    ) / 9.0
    condition = (gradient_magnitude > 30.0) & (current > 0.3) & (current < 0.7)
    adjusted = np.clip(current + np.where(neighborhood > 0.5, 0.1, -0.1), 0.0, 1.0)
    enhanced[1:-1, 1:-1] = np.where(condition, adjusted, current)
    return enhanced


def _smooth_mask(mask: Any, *, np: Any) -> Any:
    padded = np.pad(mask, 1, mode="constant", constant_values=0.0)
    padded_counts = np.pad(np.ones_like(mask), 1, mode="constant", constant_values=0.0)
    total = np.zeros_like(mask)
    count = np.zeros_like(mask)
    for offset_y in range(3):
        for offset_x in range(3):
            total += padded[offset_y : offset_y + mask.shape[0], offset_x : offset_x + mask.shape[1]]
            count += padded_counts[offset_y : offset_y + mask.shape[0], offset_x : offset_x + mask.shape[1]]
    return np.divide(total, count, out=np.zeros_like(total), where=count != 0)


def _static_shape(shape: Any) -> tuple[int, ...] | None:
    if not isinstance(shape, (list, tuple)) or any(not isinstance(value, int) for value in shape):
        return None
    return tuple(shape)


def _load_numpy() -> Any:
    try:
        import numpy as np
    except ImportError as error:
        raise RuntimeError(
            "NumPy is required for background removal; "
            "install the CLI dependencies with: python -m pip install -r requirements.txt"
        ) from error
    return np
