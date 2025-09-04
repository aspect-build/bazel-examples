const Shared = require('@bazel-examples/shared');
const Two = require('@bazel-examples/two');
const IQuote = require('inspirational-quotes');
const TQuote = require('trek-quotes');

Shared.shared();
Two();
console.log(IQuote.getRandomQuote());
console.log(TQuote.randomQuote());
