import type * as Ort from 'onnxruntime-web';

import type { Models } from './classify';
import { BACKGROUND_MODEL_SIZE, INPUT_SIZE } from './imageProcessing';
import { BACKGROUND_INPUT_NAME, maskFromTensor } from './modelValidation';

/** Run validated ONNX Runtime sessions as the classification pipeline's models. */
export function createModels(
  ort: Pick<typeof Ort, 'Tensor'>,
  background: Ort.InferenceSession,
  classifier: Ort.InferenceSession,
  labelCount: number,
): Models {
  return {
    async segment(input) {
      const outputs = await background.run({
        [BACKGROUND_INPUT_NAME]: new ort.Tensor('float32', input, [1, 3, BACKGROUND_MODEL_SIZE, BACKGROUND_MODEL_SIZE]),
      });
      const mask = outputs[background.outputNames[0]!];
      if (!mask) {
        throw new Error('background-removal model returned no mask output');
      }
      return maskFromTensor(mask.dims, mask.data);
    },
    async classify(input) {
      const outputs = await classifier.run({
        [classifier.inputNames[0]!]: new ort.Tensor('float32', input, [1, INPUT_SIZE, INPUT_SIZE, 3]),
      });
      const scores = outputs[classifier.outputNames[0]!];
      if (!scores || scores.dims.join() !== `1,${labelCount}`) {
        throw new Error(`the classifier output shape is (${scores?.dims.join(', ')}); expected (1, ${labelCount})`);
      }
      return scores.data as Float32Array;
    },
  };
}
