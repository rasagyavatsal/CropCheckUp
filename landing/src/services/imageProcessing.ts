export const MAX_IMAGE_DIMENSION = 1024;
export const MODEL_INPUT_SIZE = 224;
export const BACKGROUND_MODEL_SIZE = 320;

/** Decode a browser-selected image without uploading it anywhere. */
export async function decodeImage(file: Blob): Promise<HTMLImageElement> {
  const objectUrl = URL.createObjectURL(file);
  try {
    const image = new Image();
    image.decoding = 'async';
    image.src = objectUrl;
    await image.decode();
    return image;
  } finally {
    URL.revokeObjectURL(objectUrl);
  }
}

/** Keep the same max-width/max-height contract as the former picker flow. */
export function resizeToMaxDimension(
  image: CanvasImageSource,
  maxDimension = MAX_IMAGE_DIMENSION,
): HTMLCanvasElement {
  const { width, height } = imageDimensions(image);
  const scale = Math.min(1, maxDimension / Math.max(width, height));
  const canvas = document.createElement('canvas');
  canvas.width = Math.max(1, Math.round(width * scale));
  canvas.height = Math.max(1, Math.round(height * scale));
  const context = canvas.getContext('2d');
  if (!context) {
    throw new Error('The browser could not create an image canvas.');
  }
  context.drawImage(image, 0, 0, canvas.width, canvas.height);
  return canvas;
}

/** Center-crop an image to a square and resize it for the classifier. */
export function cropResizeSquare(
  source: HTMLCanvasElement,
  size = MODEL_INPUT_SIZE,
): HTMLCanvasElement {
  const side = Math.min(source.width, source.height);
  const sourceX = (source.width - side) / 2;
  const sourceY = (source.height - side) / 2;
  const canvas = document.createElement('canvas');
  canvas.width = size;
  canvas.height = size;
  const context = canvas.getContext('2d');
  if (!context) {
    throw new Error('The browser could not create an image canvas.');
  }
  context.imageSmoothingEnabled = true;
  context.imageSmoothingQuality = 'high';
  context.drawImage(source, sourceX, sourceY, side, side, 0, 0, size, size);
  return canvas;
}

export function canvasToDataUrl(canvas: HTMLCanvasElement): string {
  return canvas.toDataURL('image/png');
}

function imageDimensions(image: CanvasImageSource): { width: number; height: number } {
  const candidate = image as unknown as {
    naturalWidth?: unknown;
    naturalHeight?: unknown;
    width?: unknown;
    height?: unknown;
  };
  if (typeof candidate.naturalWidth === 'number' && typeof candidate.naturalHeight === 'number') {
    return { width: candidate.naturalWidth, height: candidate.naturalHeight };
  }
  if (typeof candidate.width === 'number' && typeof candidate.height === 'number') {
    return { width: candidate.width, height: candidate.height };
  }
  throw new Error('Unsupported image source.');
}
