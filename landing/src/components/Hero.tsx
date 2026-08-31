import { ProductVisual } from './ProductVisual';

const notebookUrl = 'https://www.kaggle.com/code/rasagyavatsal/cropcheckup';
const datasetUrl = 'https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset';

export function Hero() {
  return (
    <section id="hero" className="section hero">
      <div className="container hero-content">
        <div className="hero-text">
          <h1 className="hero-title">CropCheckUp</h1>
          <p className="hero-subheading">
            AI-assisted crop leaf disease detection.
          </p>
          <p className="hero-description">
            CropCheckUp analyzes a leaf image, removes the background, prepares the image for a TensorFlow Lite model, and shows the predicted crop condition with confidence and management information.
          </p>
          <div className="hero-ctas">
            <a
              href={notebookUrl}
              className="btn btn-primary cta-main"
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
              <dt>224 x 224</dt>
              <dd>image input prepared for inference</dd>
            </div>
            <div>
              <dt>0-255</dt>
              <dd>RGB tensor range handled by the model</dd>
            </div>
          </dl>
        </div>
        <div className="hero-visual-wrapper">
          <ProductVisual />
        </div>
      </div>
    </section>
  );
}
