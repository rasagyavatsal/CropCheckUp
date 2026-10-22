import type { InferenceSession } from 'onnxruntime-web';

import { BACKGROUND_MODEL_SIZE, INPUT_SIZE, type Mask } from './imageProcessing';

export const BACKGROUND_INPUT_NAME = 'input.1';

type Metadata = readonly InferenceSession.ValueMetadata[];

/** Return the shape with symbolic dimensions as `null`. */
function staticShape(shape: ReadonlyArray<number | string>): (number | null)[] {
  return shape.map((dim) => (typeof dim === 'number' && dim > 0 ? dim : null));
}

function describe(shape: ReadonlyArray<number | null>): string {
  return `(${shape.map((dim) => dim ?? 'None').join(', ')})`;
}

/** Check that the classifier takes one (N, 224, 224, 3) float32 tensor and returns one tensor. */
export function validateClassifier(inputs: Metadata, outputs: Metadata): void {
  if (inputs.length !== 1 || outputs.length !== 1) {
    throw new Error('the classifier must expose one input tensor and one output tensor');
  }
  const input = inputs[0]!;
  if (!input.isTensor) {
    throw new Error('the classifier input must be a tensor');
  }
  const shape = staticShape(input.shape);
  const [batch, height, width, channels] = shape;
  if (shape.length !== 4 || (batch !== null && batch !== 1) || height !== INPUT_SIZE || width !== INPUT_SIZE || channels !== 3) {
    throw new Error(`the classifier input shape is ${describe(shape)}; expected (None or 1, 224, 224, 3)`);
  }
  if (input.type !== 'float32') {
    throw new Error(`the classifier input type is ${input.type}; expected float32`);
  }
}

/** Check the background-removal model's input name, shape and mask output. */
export function validateBackgroundModel(inputs: Metadata, outputs: Metadata): void {
  if (inputs.length !== 1) {
    throw new Error(`background-removal model exposes ${inputs.length} inputs; expected one`);
  }
  const input = inputs[0]!;
  if (input.name !== BACKGROUND_INPUT_NAME) {
    throw new Error(`background-removal model input is '${input.name}'; expected '${BACKGROUND_INPUT_NAME}'`);
  }
  if (input.isTensor) {
    const shape = staticShape(input.shape);
    const expected = [1, 3, BACKGROUND_MODEL_SIZE, BACKGROUND_MODEL_SIZE];
    if (shape.every((dim) => dim !== null) && shape.join() !== expected.join()) {
      throw new Error(`background-removal model input shape is ${describe(shape)}; expected ${describe(expected)}`);
    }
    if (input.type !== 'float32') {
      throw new Error(`background-removal model input type is ${input.type}; expected float32`);
    }
  }
  const output = outputs[0];
  if (!output) {
    throw new Error('background-removal model exposes no mask output');
  }
  if (output.isTensor) {
    const shape = staticShape(output.shape);
    if (shape.every((dim) => dim !== null) && (shape.length !== 4 || shape[0] !== 1 || shape[1] !== 1)) {
      throw new Error(`background-removal mask output shape is ${describe(shape)}; expected (1, 1, H, W)`);
    }
    if (output.type !== 'float32') {
      throw new Error(`background-removal mask output type is ${output.type}; expected float32`);
    }
  }
}

/** Read an (H, W), (1, H, W) or (1, 1, H, W) mask tensor. */
export function maskFromTensor(dims: readonly number[], data: unknown): Mask {
  if (!(data instanceof Float32Array)) {
    throw new Error('background-removal mask output must contain float32 values');
  }
  let shape = [...dims];
  if (shape.length === 4 && shape[0] === 1 && shape[1] === 1) {
    shape = shape.slice(2);
  } else if (shape.length === 3 && shape[0] === 1) {
    shape = shape.slice(1);
  }
  if (shape.length !== 2) {
    throw new Error(`background-removal mask has shape (${dims.join(', ')}); expected (H, W), (1, H, W), or (1, 1, H, W)`);
  }
  const [height, width] = shape as [number, number];
  if (width * height === 0) {
    throw new Error('background-removal mask is empty');
  }
  return { width, height, data };
}
