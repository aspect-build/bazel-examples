import { platform, arch } from 'node:os';
import { one } from '@bazel-poc/one';
import { shared } from '@bazel-poc/shared';
import { getRandomQuote } from 'inspirational-quotes';
import * as quotes from 'star-wars-quotes';

shared();
one();
console.log(getRandomQuote());
console.log(quotes());
console.log('Platform: ' + platform());
console.log('Architecture: ' + arch());
