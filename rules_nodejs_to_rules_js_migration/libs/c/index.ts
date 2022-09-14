import { a as aPrime, b as bPrime } from '../b';
import isEven from 'is-even';

import { TypeA, TypeB, TypeC } from './src/types';

export { TypeA, TypeB, TypeC } from './src/types';

export function a(): TypeA {
  return { a: `${aPrime}^c` };
}

export function b(): TypeB {
  return { b: `${bPrime}^c` };
}

export function c(): TypeC {
  return { c: 'c' };
}

export function isEvener(num: number): boolean {
  return isEven(num);
}
