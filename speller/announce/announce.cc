#include "announce.h"

#include <ctime>
#include <iostream>

// Bazel recommends that your code refer to each header from the
// workspace root. There is a way to support "greeting.h" instead, for
// compatibility with code written that way, but I can't recall it
// while writing this comment.

#include "speller/greeting/greeting.h"

namespace Speller {

void announce(const std::string &word) {
  std::time_t result = std::time(nullptr);
  std::cout << std::endl
            << "Speller executed at "
            << std::asctime(std::localtime(&result));
  std::cout << get_greet(word) << std::endl;
}

}  // namespace Speller
