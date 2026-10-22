import { useEffect, useRef } from 'react';

import type { RgbaImage } from '../lib/imageProcessing';

/** Show the exact classifier input and offer it as a lossless PNG. */
export function ProcessedPreview({ image, fileName }: { image: RgbaImage; fileName: string }) {
  const canvas = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const context = canvas.current?.getContext('2d');
    context?.putImageData(new ImageData(new Uint8ClampedArray(image.data), image.width, image.height), 0, 0);
  }, [image]);

  const download = () => {
    canvas.current?.toBlob((blob) => {
      if (!blob) return;
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = `${fileName.replace(/\.[^.]+$/, '')}-processed.png`;
      link.click();
      URL.revokeObjectURL(link.href);
    }, 'image/png');
  };

  return (
    <figure className="photo">
      <canvas ref={canvas} width={image.width} height={image.height} aria-label="Classifier input" />
      <figcaption>
        Classifier input · {image.width}×{image.height}
        <button type="button" className="link-button" onClick={download}>
          Save PNG
        </button>
      </figcaption>
    </figure>
  );
}
