import { format } from 'node:util';
export function one() {
  console.log(format('I am %s, not %s!', 'One', 'Two'));
}
