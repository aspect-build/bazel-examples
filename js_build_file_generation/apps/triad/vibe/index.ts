import { pitchName } from '@example/iris';
import { name as asapName } from '../../../libs/rune/asap';

export function name(): string {
  return 'vibe';
}

export function info(): string[] {
  return [pitchName(), asapName()];
}
