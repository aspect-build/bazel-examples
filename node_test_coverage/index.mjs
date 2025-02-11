import { format } from 'node:util';
export function one() {
  return format('I am %s, not %s!', 'One', 'Two');
}
