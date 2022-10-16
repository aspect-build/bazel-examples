import { name } from './a';
import { fixture } from '@open-wc/testing-helpers';

it('can instantiate an element', async () => {
  const el = await fixture('<my-el foo="bar"></my-el>');
  expect(el.getAttribute('foo')).toEqual('bar');
});

it('a', () => {
  expect(name()).toBe('a');
});
