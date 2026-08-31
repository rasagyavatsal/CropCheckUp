import { Icon } from './Icon';

const outputFields = [
  'Crop name',
  'Disease or healthy status',
  'Confidence percentage',
  'Symptoms',
  'Possible causes',
  'Management guidance',
  'Processed leaf preview',
];

export function ModelOutput() {
  return (
    <section id="model-output" className="section">
      <div className="container">
        <div className="section-header model-section-header">
          <h2>Model <span className="text-highlight">Output</span></h2>
          <p className="section-subtitle">
            The classifier returns one top label and a score. The app turns that raw model output into a result a grower can scan quickly: crop, condition, confidence, symptoms, causes, management guidance, and the processed leaf preview.
          </p>
        </div>

        <div className="output-layout">
          <article className="explanation-card">
            <div className="card-heading">
              <Icon name="brain" size={48} className="card-icon" />
              <h3>Readable Classification</h3>
            </div>
            <p>
              The classifier returns the highest-scoring label from the model output. Labels follow a crop and condition format such as <code className="code-badge">Crop___Disease</code> or <code className="code-badge">Crop___healthy</code>.
            </p>
            <p>
              The app converts raw labels into readable crop and disease names, keeps the confidence percentage visible, and separates advisory content from the model prediction.
            </p>

            <div className="info-alert">
              <Icon name="info" size={20} className="alert-icon" />
              <p><strong>Label file:</strong> The current label file contains 68 crop and condition labels.</p>
            </div>
          </article>

          <article className="example-panel">
            <h3>Example Diagnosis</h3>

            <div className="conversion-visual">
              <div className="label-box raw">
                <span className="label-type">Raw Label</span>
                <span className="label-value font-mono">Tomato___Late_blight</span>
              </div>

              <div className="conversion-arrow" aria-hidden="true">
                <div className="arrow-line" />
                <div className="arrow-head" />
              </div>

              <div className="label-box processed">
                <span className="label-type">Displayed Result</span>
                <span className="label-value text-highlight font-bold">Tomato - Late blight</span>
              </div>
            </div>

            <div className="output-fields">
              <h4>Output Information</h4>
              <div className="fields-grid">
                {outputFields.map((field) => (
                  <div className="field-item" key={field}>
                    <Icon name="check" size={16} className="check-icon" />
                    {field}
                  </div>
                ))}
              </div>
            </div>
          </article>
        </div>
      </div>
    </section>
  );
}
