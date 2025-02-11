import assert from 'node:assert';
import { mock, test } from 'node:test';
import { one } from './index.mjs';

test('calls first-party library', () => {
  assert.equal(one(), 'I am One, not Two!');
});

test('spies on a function', () => {
  const sum = mock.fn((a, b) => {
    return a + b;
  });

  assert.strictEqual(sum.mock.callCount(), 0);
  assert.strictEqual(sum(3, 4), 7);
  assert.strictEqual(sum.mock.callCount(), 1);

  const call = sum.mock.calls[0];
  assert.deepStrictEqual(call.arguments, [3, 4]);
  assert.strictEqual(call.result, 7);
  assert.strictEqual(call.error, undefined);

  // Reset the globally tracked mocks.
  mock.reset();
});
