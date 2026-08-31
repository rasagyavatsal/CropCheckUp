# Privacy Documentation

- CropCheckUp is an upload-only website. It does not request device capture or microphone access.
- The website does not require account creation.
- The website does not include analytics, ads, or telemetry.
- Selected PNG, JPEG, and WebP images are decoded, segmented, resized, and classified locally in the browser.
- Plant images are not uploaded to an application server or diagnosis API.
- Diagnosis history is stored locally in IndexedDB when available. A local-storage fallback is used when IndexedDB is unavailable.
- The website retains at most 20 history entries and displays the latest 10. A history entry includes the processed image data URL and diagnosis metadata.
- Clearing the website's site data removes locally stored diagnosis history.
- External links in the documentation and website may open GitHub or Kaggle and are governed by those services' policies.
