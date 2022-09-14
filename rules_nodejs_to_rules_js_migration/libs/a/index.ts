import isEven from 'is-even';
import { TypeA } from './src/types';

export { TypeA } from './src/types';

export function a(): TypeA {
  return { a: 'a' };
}

export function isEvener(num: number): boolean {
  return isEven(num);
}
