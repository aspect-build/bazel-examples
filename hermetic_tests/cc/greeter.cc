#include "hermetic_tests/cc/greeter.h"

#include <string>

std::string Greet(const std::string& name) {
  return "Hello, " + name + "!";
}
