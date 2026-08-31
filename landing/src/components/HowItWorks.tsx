import { Icon, type IconName } from './Icon';

type Step = {
  title: string;
  description: string;
  detail: string;
  checks: string[];
  icon: IconName;
};

const steps: Step[] = [
  {
    title: 'Capture or upload',
    description: 'The user captures a live camera frame or selects an image from the gallery.',
    detail: 'CropCheckUp starts with one visible leaf. A clean single-subject image gives the downstream segmentation and classifier less irrelevant texture to absorb.',
    checks: ['Camera or gallery input', 'Single leaf only', 'Visible disease area'],
    icon: 'camera',
  },
  {
    title: 'Remove background',
    description: 'The app isolates the leaf so the classifier focuses on the plant area.',
    detail: 'Background removal reduces noise from soil, hands, pots, shadows, and neighboring plants before the model sees the image.',
    checks: ['Leaf mask extracted', 'Non-leaf pixels suppressed', 'Transparent pixels handled later'],
    icon: 'remove-background',
  },
  {
    title: 'Resize image',
    description: 'The processed image is resized to 224 x 224 pixels.',
    detail: 'Every image is normalized to the same square input size, matching the TensorFlow Lite model shape used during training and export.',
    checks: ['Consistent input shape', 'Aspect handled before tensor conversion', 'Model-ready dimensions'],
    icon: 'resize',
  },
  {
    title: 'Run inference',
    description: 'A TensorFlow Lite model predicts the most likely crop condition.',
    detail: 'The app converts the resized RGB image into a tensor, runs local inference, and reads the top-scoring label from the output vector.',
    checks: ['RGB tensor generated', '0-255 value range', 'Highest score selected'],
    icon: 'zap',
  },
  {
    title: 'Show diagnosis',
    description: 'The app displays crop name, condition, confidence, symptoms, causes, and management guidance.',
    detail: 'Raw model labels are translated into readable names and paired with the supporting context a user needs before deciding what to inspect next.',
    checks: ['Readable crop and condition', 'Confidence percentage', 'Symptoms and next steps'],
    icon: 'chart',
  },
];

export function HowItWorks() {
  return (
    <section id="how-it-works" className="section">
      <div className="container">
        <div className="section-header">
          <h2>How It <span className="text-highlight">Works</span></h2>
          <p className="section-subtitle">
            The app is intentionally narrow: one leaf image goes through segmentation, model-ready preprocessing, TensorFlow Lite inference, then a readable diagnosis summary.
          </p>
        </div>

        <div className="workflow-grid">
          {steps.map((step, index) => (
            <article className="workflow-card" key={step.title}>
              <div className="card-header">
                <span className="step-icon"><Icon name={step.icon} /></span>
                <span className="step-number">{String(index + 1).padStart(2, '0')}</span>
              </div>
              <h3 className="step-title">{step.title}</h3>
              <p className="step-description">{step.description}</p>
              <p className="step-detail">{step.detail}</p>
              <ul className="check-list">
                {step.checks.map((check) => <li key={check}>{check}</li>)}
              </ul>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
