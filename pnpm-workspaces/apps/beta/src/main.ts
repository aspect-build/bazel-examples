import { two } from '@bazel-poc/two';
import { shared } from '@bazel-poc/shared';
import { getRandomQuote } from 'inspirational-quotes';
import { randomQuote } from 'trek-quotes';

shared()
two()
console.log(getRandomQuote())
console.log(randomQuote())
