import type { ReactNode } from 'react';

import { Icon } from './Icon';

type Rule = {
  icon: 'camera' | 'ban' | 'target';
  children: ReactNode;
};

const rules: Rule[] = [
  {
    icon: 'camera',
    children: <><strong>Use a clear image of one leaf.</strong> Keep the leaf in focus, fill the frame with the relevant surface, and avoid mixing multiple plants in one capture.</>,
  },
  {
    icon: 'ban',
    children: <><strong>Avoid blur, shadows, and cluttered backgrounds.</strong> Harsh light, dark shadows, soil texture, hands, and pots can make segmentation and classification less reliable.</>,
  },
  {
    icon: 'target',
    children: <><strong>The app can only classify supported labels.</strong> Unknown crops, new diseases, mixed symptoms, pests, nutrient stress, or water damage may still map to the nearest known label.</>,
  },
];

export function Limitations() {
  return (
    <section id="limitations" className="section">
      <div className="container">
        <div className="limitations-wrapper">
          <div className="limitations-content">
            <h2>Important Limitations</h2>
            <p className="intro-text">
              CropCheckUp is an AI-assisted screening tool. Results depend on image quality, lighting, leaf visibility, and whether the condition exists in the trained labels.
            </p>

            <div className="rules-grid">
              {rules.map((rule) => (
                <div className="rule-item" key={rule.icon}>
                  <span className="rule-bullet"><Icon name={rule.icon} /></span>
                  <p>{rule.children}</p>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
