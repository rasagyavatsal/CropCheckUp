import { useEffect, useState } from 'react';

function firstImage(files: FileList | DataTransferItemList | undefined | null): File | undefined {
  for (const item of Array.from<File | DataTransferItem>(files ?? [])) {
    const file = item instanceof File ? item : item.kind === 'file' ? item.getAsFile() : null;
    if (file?.type.startsWith('image/')) return file;
  }
  return undefined;
}

/** Choose a photo by clicking, dropping or pasting. */
export function ImagePicker({ onImage, compact }: { onImage(file: File): void; compact: boolean }) {
  const [dragging, setDragging] = useState(false);

  useEffect(() => {
    const onPaste = (event: ClipboardEvent) => {
      const file = firstImage(event.clipboardData?.items);
      if (file) onImage(file);
    };
    window.addEventListener('paste', onPaste);
    return () => window.removeEventListener('paste', onPaste);
  }, [onImage]);

  return (
    <label
      className={`dropzone${dragging ? ' dropzone-active' : ''}${compact ? ' dropzone-compact' : ''}`}
      onDragOver={(event) => {
        event.preventDefault();
        setDragging(true);
      }}
      onDragLeave={(event) => {
        if (!event.currentTarget.contains(event.relatedTarget as Node | null)) setDragging(false);
      }}
      onDrop={(event) => {
        event.preventDefault();
        setDragging(false);
        const file = firstImage(event.dataTransfer.files);
        if (file) onImage(file);
      }}
    >
      <input
        type="file"
        accept="image/*"
        className="visually-hidden"
        onChange={(event) => {
          const file = firstImage(event.target.files);
          if (file) onImage(file);
          event.target.value = '';
        }}
      />
      <svg viewBox="0 0 24 24" aria-hidden="true" className="dropzone-icon">
        <path d="M12 16V4m0 0-4 4m4-4 4 4M4 16v2a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-2" />
      </svg>
      <span className="dropzone-title">{compact ? 'Check another leaf' : 'Choose a leaf photo'}</span>
      {!compact && <span className="dropzone-hint">or drop or paste one here · JPEG, PNG or WebP</span>}
    </label>
  );
}
