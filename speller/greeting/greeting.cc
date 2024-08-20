#include "speller/greeting/greeting.h"

#include <string>

namespace Speller {

std::string get_greet(const std::string& word) {
  return "Looking up whether '" + word + "' is a valid word";
}

}  // namespace Speller
