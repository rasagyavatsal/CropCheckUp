import { useEffect, useRef, useState } from 'react';

import { Icon } from './Icon';

const lightVideoSrc = '/videos/light.mp4';
const darkVideoSrc = '/videos/dark.mp4';

function getThemeVideoSource(): string {
  return document.documentElement.classList.contains('dark')
    ? darkVideoSrc
    : lightVideoSrc;
}

export function ProductVisual() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [isReady, setIsReady] = useState<boolean>(false);

  useEffect(() => {
    const video = videoRef.current;
    if (!video) {
      return undefined;
    }

    const updateThemeVideo = (): void => {
      const nextSource = getThemeVideoSource();
      if (video.dataset.currentSrc === nextSource) {
        return;
      }

      video.dataset.currentSrc = nextSource;
      setIsReady(false);
      video.src = nextSource;
      video.load();
      void video.play().catch(() => undefined);
    };

    const handleLoadedData = (): void => setIsReady(true);
    const handleError = (): void => setIsReady(false);

    video.addEventListener('loadeddata', handleLoadedData);
    video.addEventListener('error', handleError);
    updateThemeVideo();

    const themeObserver = new MutationObserver(updateThemeVideo);
    themeObserver.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ['class'],
    });

    return () => {
      video.removeEventListener('loadeddata', handleLoadedData);
      video.removeEventListener('error', handleError);
      themeObserver.disconnect();
    };
  }, []);

  return (
    <div className="product-visual mobile-frame glass-panel">
      <div className="video-container">
        <video
          ref={videoRef}
          className={`app-video${isReady ? ' is-ready' : ''}`}
          data-theme-video="true"
          data-light-src={lightVideoSrc}
          data-dark-src={darkVideoSrc}
          autoPlay
          loop
          muted
          playsInline
          preload="metadata"
          aria-label="CropCheckUp mobile app walkthrough"
        />

        <div className="video-fallback" aria-hidden="true">
          <div className="scan-line" />
          <div className="fallback-header">
            <span className="status-dot" />
            CropCheckUp demo
          </div>
          <div className="play-icon">
            <Icon name="play" size={48} />
          </div>
          <p>Loading walkthrough</p>
          <p className="small-text">Mobile app demo</p>
        </div>
      </div>
    </div>
  );
}
