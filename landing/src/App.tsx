import { DiagnosisWorkspace } from './components/DiagnosisWorkspace';
import { DatasetReferences } from './components/DatasetReferences';
import { Hero } from './components/Hero';
import { HowItWorks } from './components/HowItWorks';
import { Limitations } from './components/Limitations';
import { ModelOutput } from './components/ModelOutput';
import { ProcessingPipeline } from './components/ProcessingPipeline';
import { SiteFooter } from './components/SiteFooter';
import { SiteHeader } from './components/SiteHeader';

export function App() {
  return (
    <>
      <SiteHeader />
      <main>
        <Hero />
        <DiagnosisWorkspace />
        <HowItWorks />
        <ProcessingPipeline />
        <ModelOutput />
        <DatasetReferences />
        <Limitations />
      </main>
      <SiteFooter />
    </>
  );
}
