import isOdd from 'is-odd';
import { TypeA } from './src/types';

export { TypeA } from './src/types';

export function a(): TypeA {
  return { a: 'a' };
}

export function isOdder(num: number): boolean {
  return isOdd(num);
}
