import { Icon, type IconName } from './Icon';

type Stage = {
  name: string;
  detail: string;
  icon: IconName;
};

const stages: Stage[] = [
  { name: 'Camera / Gallery', detail: 'Raw leaf photo enters from the mobile capture flow.', icon: 'device' },
  { name: 'Background removal', detail: 'Leaf pixels are isolated so the model sees less surrounding scene noise.', icon: 'remove-background' },
  { name: '224 x 224 image', detail: "The isolated image is resized to the model's expected square input.", icon: 'image' },
  { name: 'RGB tensor', detail: 'Pixels are packed as RGB values before inference.', icon: 'grid' },
  { name: 'TensorFlow Lite inference', detail: 'The on-device model returns a score vector across the label file.', icon: 'brain' },
  { name: 'Diagnosis result', detail: 'The top label is converted into crop, condition, confidence, and guidance.', icon: 'chart' },
];

export function ProcessingPipeline() {
  return (
    <section id="pipeline" className="section">
      <div className="container">
        <div className="section-header">
          <h2>Processing <span className="text-highlight">Pipeline</span></h2>
          <p className="section-subtitle">
            The landing page exposes the exact assumptions that matter for this app: input size, color channel handling, label conversion, and what happens to transparent background pixels.
          </p>
        </div>

        <div className="pipeline-wrapper">
          <div className="pipeline-flow">
            {stages.map((stage, index) => (
              <div className="stage-container" key={stage.name}>
                <div className="stage-node">
                  <div className="stage-icon"><Icon name={stage.icon} /></div>
                </div>
                <div className="stage-label">{stage.name}</div>
                <p className="stage-detail">{stage.detail}</p>
                {index < stages.length - 1 && (
                  <div className="connector-line" aria-hidden="true">
                    <div className="moving-dot" />
                  </div>
                )}
              </div>
            ))}
          </div>

          <div className="technical-notes">
            <div className="note-icon"><Icon name="bulb" /></div>
            <div className="note-content">
              <h3>Preprocessing contract</h3>
              <p>The model receives a 224 x 224 RGB image. Pixel values are passed in the 0-255 range because preprocessing is included inside the model.</p>
              <p>Transparent background pixels are treated as black during tensor conversion.</p>
              <p>The highest scoring label is resolved against the app's label file before the result screen is rendered.</p>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
