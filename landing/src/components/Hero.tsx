import { Icon } from './Icon';

const notebookUrl = 'https://www.kaggle.com/code/rasagyavatsal/cropcheckup';
const datasetUrl = 'https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset';

export function Hero() {
  return (
    <section id="hero" className="section hero">
      <div className="container hero-content">
        <div className="hero-text">
          <p className="eyebrow">Local AI · Browser ready</p>
          <h1 className="hero-title">CropCheckUp</h1>
          <p className="hero-subheading">
            AI-assisted crop leaf disease detection.
          </p>
          <p className="hero-description">
            Upload a leaf image and CropCheckUp removes the background, prepares the image for a TensorFlow Lite model, and shows the predicted crop condition with confidence and management information.
          </p>
          <div className="hero-ctas">
            <a href="#diagnose" className="btn btn-primary cta-main">Check a leaf</a>
            <a
              href={notebookUrl}
              className="btn btn-outline cta-secondary"
              target="_blank"
              rel="noopener noreferrer"
            >
              View Kaggle Notebook
            </a>
            <a
              href={datasetUrl}
              className="btn btn-outline cta-secondary"
              target="_blank"
              rel="noopener noreferrer"
            >
              View Dataset
            </a>
          </div>
          <dl className="hero-metrics" aria-label="CropCheckUp model facts">
            <div>
              <dt>68</dt>
              <dd>crop and condition labels</dd>
            </div>
            <div>
              <dt>224 × 224</dt>
              <dd>image input prepared for inference</dd>
            </div>
            <div>
              <dt>0–255</dt>
              <dd>RGB tensor range handled by the model</dd>
            </div>
          </dl>
        </div>
        <div className="hero-visual-wrapper">
          <div className="hero-browser-card glass-panel">
            <div className="browser-card-topline">
              <span className="browser-dot is-green" />
              <span className="browser-dot is-blue" />
              <span className="browser-dot is-muted" />
              <span className="browser-address">cropcheckup / diagnose</span>
            </div>
            <div className="browser-card-body">
              <span className="hero-preview-icon"><Icon name="image" size={42} /></span>
              <strong>Upload one clear leaf photo</strong>
              <span>Segment · resize · classify</span>
              <div className="hero-preview-flow">
                <span>Local processing</span><Icon name="zap" size={16} /><span>Private result</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
