import chalk from 'chalk';
import { whoami as whoisrigel } from 'rigel';

export function whoami() {
  return chalk.green('vega');
}

console.log(whoami());
console.log(whoisrigel().toUpperCase());
