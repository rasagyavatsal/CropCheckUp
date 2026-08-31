import packageJson from '../../package.json';

const notebookUrl = 'https://www.kaggle.com/code/rasagyavatsal/cropcheckup';
const datasetUrl = 'https://www.kaggle.com/datasets/rasagyavatsal/cropcheckup-dataset';
const repositoryUrl = 'https://github.com/rasagyavatsal/CropCheckUp';
const landingVersion = packageJson.version;

export function SiteFooter() {
  return (
    <footer className="site-footer">
      <div className="container footer-container">
        <div className="footer-top">
          <div className="footer-info">
            <div className="footer-logo">
              <img
                src="/logo.png"
                width="24"
                height="24"
                alt=""
                className="footer-logo-icon"
                aria-hidden="true"
              />
              <span className="logo-text">
                Crop<span className="text-highlight">CheckUp</span>
              </span>
            </div>
            <p className="description">
              AI-assisted plant disease detection. Built for single-leaf image analysis with background removal, model-ready preprocessing, and local browser inference.
            </p>
          </div>

          <div className="footer-nav-groups">
            <div className="nav-group">
              <h4>Project</h4>
              <a href="#how-it-works">How It Works</a>
              <a href="#pipeline">Pipeline</a>
              <a href="#model-output">Model Output</a>
              <a href="#limitations">Limitations</a>
            </div>

            <div className="nav-group">
              <h4>Resources</h4>
              <a href={notebookUrl} target="_blank" rel="noopener noreferrer">Kaggle Notebook</a>
              <a href={datasetUrl} target="_blank" rel="noopener noreferrer">Dataset</a>
              <a href={repositoryUrl} target="_blank" rel="noopener noreferrer">GitHub Repo</a>
            </div>
          </div>
        </div>

        <div className="footer-bottom">
          <p className="copyright">© {new Date().getFullYear()} CropCheckUp.</p>
          <p className="version">Website v{landingVersion}</p>
          <p className="license-summary">
            <a href={`${repositoryUrl}/blob/main/LICENSE`} target="_blank" rel="noopener noreferrer">Code: Apache-2.0</a>.{' '}
            <a href={`${repositoryUrl}/blob/main/DATASET_LICENSE.md`} target="_blank" rel="noopener noreferrer">Model/data: CC-BY-NC-SA-4.0 non-commercial</a>.
          </p>
        </div>
      </div>
    </footer>
  );
}
