import { a as aPrime } from '@example/pkg-a';
import isOdd from 'is-odd';
import { TypeA, TypeB } from './src/types';

export { TypeA, TypeB } from './src/types';

export function a(): TypeA {
  return { a: `${aPrime}^b` };
}

export function b(): TypeB {
  return { b: 'b' };
}

export function isOdder(num: number): boolean {
  return isOdd(num);
}
