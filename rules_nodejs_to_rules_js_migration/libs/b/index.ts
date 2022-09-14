import { a as aPrime } from '../a';
import isEven from 'is-even';
import { TypeA, TypeB } from './src/types';

export { TypeA, TypeB } from './src/types';

export function a(): TypeA {
  return { a: `${aPrime}^b` };
}

export function b(): TypeB {
  return { b: 'b' };
}

export function isEvener(num: number): boolean {
  return isEven(num);
}
