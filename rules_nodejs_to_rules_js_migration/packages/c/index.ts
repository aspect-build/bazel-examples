import { a as aPrime, b as bPrime } from '@example/pkg-b';
import isOdd from 'is-odd';

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

export function isOdder(num: number): boolean {
  return isOdd(num);
}
