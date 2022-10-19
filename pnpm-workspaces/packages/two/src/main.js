const cowsay = require('cowsay');
const First = require('@bazel-poc/first');

module.exports = two = () => {
  First();
  console.log('I am Two, not One!');
  console.log(
    cowsay.say({
      text: "I'm a transitive moooodule",
      e: 'oO',
      T: 'U ',
    })
  );
};
