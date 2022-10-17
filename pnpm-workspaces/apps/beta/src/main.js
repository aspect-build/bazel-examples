const Shared = require('@bazel-poc/shared');
const Two = require('@bazel-poc/two');
const IQuote = require('inspirational-quotes');
const TQuote = require('trek-quotes');

Shared.shared();
Two();
console.log(IQuote.getRandomQuote());
console.log(TQuote.randomQuote());
