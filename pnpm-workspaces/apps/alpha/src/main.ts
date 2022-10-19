import { one } from '@bazel-poc/one';
import { shared } from '@bazel-poc/shared';
import { getRandomQuote } from 'inspirational-quotes';
import quotes from 'star-wars-quotes';

shared();
one();
console.log(getRandomQuote());
console.log(quotes());
