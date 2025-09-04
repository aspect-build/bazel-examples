import { format } from 'node:util';
export function shared() {
  console.log(format('Sharing is indeed %s!', 'caring'));
}
