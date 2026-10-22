import type { InferenceSession } from 'onnxruntime-web';
import { describe, expect, it } from 'vitest';

import { maskFromTensor, validateBackgroundModel, validateClassifier } from './modelValidation';

function tensor(name: string, shape: (number | string)[], type = 'float32'): InferenceSession.ValueMetadata {
  return { name, isTensor: true, shape, type } as InferenceSession.ValueMetadata;
}

describe('validateClassifier', () => {
  it('accepts a dynamic or single batch', () => {
    expect(() => validateClassifier([tensor('x', ['batch', 224, 224, 3])], [tensor('y', ['batch', 38])])).not.toThrow();
    expect(() => validateClassifier([tensor('x', [1, 224, 224, 3])], [tensor('y', [1, 38])])).not.toThrow();
  });

  it('rejects other shapes and types', () => {
    expect(() => validateClassifier([tensor('x', [1, 3, 224, 224])], [tensor('y', [1, 38])])).toThrow(
      'the classifier input shape is (1, 3, 224, 224)',
    );
    expect(() => validateClassifier([tensor('x', [1, 224, 224, 3], 'uint8')], [tensor('y', [1, 38])])).toThrow('expected float32');
    expect(() => validateClassifier([], [])).toThrow('one input tensor and one output tensor');
  });
});

describe('validateBackgroundModel', () => {
  const output = tensor('mask', [1, 1, 320, 320]);

  it('accepts the bundled model layout', () => {
    expect(() => validateBackgroundModel([tensor('input.1', [1, 3, 320, 320])], [output])).not.toThrow();
  });

  it('rejects a different input name or shape', () => {
    expect(() => validateBackgroundModel([tensor('image', [1, 3, 320, 320])], [output])).toThrow("expected 'input.1'");
    expect(() => validateBackgroundModel([tensor('input.1', [1, 3, 256, 256])], [output])).toThrow('input shape is (1, 3, 256, 256)');
    expect(() => validateBackgroundModel([tensor('input.1', [1, 3, 320, 320])], [tensor('mask', [1, 2, 320, 320])])).toThrow(
      'expected (1, 1, H, W)',
    );
  });
});

describe('maskFromTensor', () => {
  it('accepts 2, 3 and 4 dimensional masks', () => {
    const data = new Float32Array(6);
    for (const dims of [[2, 3], [1, 2, 3], [1, 1, 2, 3]]) {
      expect(maskFromTensor(dims, data)).toMatchObject({ width: 3, height: 2 });
    }
  });

  it('rejects other layouts and data types', () => {
    expect(() => maskFromTensor([2, 2, 3], new Float32Array(12))).toThrow('expected (H, W)');
    expect(() => maskFromTensor([2, 3], new Uint8Array(6))).toThrow('float32 values');
    expect(() => maskFromTensor([0, 3], new Float32Array(0))).toThrow('empty');
  });
});
