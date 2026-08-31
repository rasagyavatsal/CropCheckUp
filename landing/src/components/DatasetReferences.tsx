import { Icon } from './Icon';

const notebookUrl = 'https://www.kaggle.com/code/rasagyavatsal/cropcheckup';
const datasetUrl = 'https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset';

type Resource = {
  title: string;
  description: string;
  checks: string[];
  action: string;
  href: string;
  icon: 'book' | 'folder';
};

const resources: Resource[] = [
  {
    title: 'Kaggle Notebook',
    description: 'Model development workflow and experimentation.',
    checks: ['Training and validation flow', 'Model export assumptions', 'Notebook-level experiment trace'],
    action: 'View Code',
    href: notebookUrl,
    icon: 'book',
  },
  {
    title: 'CropCheckUp Dataset',
    description: 'Image dataset used for CropCheckUp experiments and training.',
    checks: ['Crop and condition image labels', 'Training data reference', 'Dataset source for reproducibility'],
    action: 'Download Data',
    href: datasetUrl,
    icon: 'folder',
  },
];

export function DatasetReferences() {
  return (
    <section id="dataset" className="section">
      <div className="container">
        <div className="section-header">
          <h2>Resources & <span className="text-highlight">Datasets</span></h2>
          <p className="section-subtitle">
            The model development workflow is documented in the Kaggle notebook. The dataset used for CropCheckUp experiments and training is available on Kaggle.
          </p>
        </div>

        <div className="resources-grid">
          {resources.map((resource) => (
            <a
              href={resource.href}
              target="_blank"
              rel="noopener noreferrer"
              className="resource-card glass-panel"
              key={resource.title}
            >
              <div className="resource-icon"><Icon name={resource.icon} size={48} /></div>
              <div className="resource-content">
                <h3>{resource.title}</h3>
                <p>{resource.description}</p>
                <ul className="resource-list">
                  {resource.checks.map((check) => <li key={check}>{check}</li>)}
                </ul>
              </div>
              <div className="resource-action">
                <span className="action-text">{resource.action}</span>
                <span className="arrow">-&gt;</span>
              </div>
            </a>
          ))}
        </div>

        <div className="dataset-attribution">
          <h3>Source Dataset Attribution</h3>
          <ul>
            <li><strong>PlantVillage:</strong> Licensed under CC-BY-NC-SA-4.0</li>
            <li><strong>Mango Leaf Disease:</strong> Licensed under CC-BY-NC-4.0</li>
          </ul>
          <p className="license-statement">CropCheckUp derived dataset and bundled model artifacts are licensed CC-BY-NC-SA-4.0 for non-commercial use.</p>
        </div>
      </div>
    </section>
  );
}
