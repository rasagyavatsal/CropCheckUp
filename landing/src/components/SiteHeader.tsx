import { ThemeToggle } from './ThemeToggle';

const notebookUrl = 'https://www.kaggle.com/code/rasagyavatsal/cropcheckup';

export function SiteHeader() {
  return (
    <header className="site-header glass-panel">
      <div className="container header-container">
        <div className="header-logo">
          <img
            src="/logo.png"
            width="28"
            height="28"
            alt=""
            className="header-logo-icon"
            aria-hidden="true"
          />
          <span className="logo-text">
            Crop<span className="text-highlight">CheckUp</span>
          </span>
        </div>

        <nav className="main-nav" aria-label="Primary navigation">
          <a href="#how-it-works" className="nav-link">Workflow</a>
          <a href="#pipeline" className="nav-link">Pipeline</a>
          <a href="#model-output" className="nav-link">Output</a>
          <a href="#dataset" className="nav-link">Dataset</a>
          <a href="#limitations" className="nav-link">Limits</a>
        </nav>

        <div className="header-actions">
          <ThemeToggle />
          <a
            href={notebookUrl}
            className="btn btn-primary nav-cta"
            target="_blank"
            rel="noopener noreferrer"
          >
            Kaggle Notebook
          </a>
        </div>
      </div>
    </header>
  );
}
