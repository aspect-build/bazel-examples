import { platform, arch } from 'node:os';
import { one } from '@bazel-examples/one';
import { shared } from '@bazel-examples/shared';
import { rust, c } from '@bazel-examples/napi';
import { getRandomQuote } from 'inspirational-quotes';
import * as quotes from 'star-wars-quotes';

shared();
one();
console.log(getRandomQuote());
console.log(quotes());
console.log(rust.hello('NodeJS'));
console.log('C code does math: 1 + 2 = ' + c.add(1, 2));
console.log('Platform: ' + platform());
console.log('Architecture: ' + arch());
