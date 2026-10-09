#include "hermetic_tests/cc/greeter.h"

#include "gtest/gtest.h"

TEST(GreeterTest, Greets) {
  EXPECT_EQ(Greet("World"), "Hello, World!");
}

TEST(GreeterTest, HermeticToolchain) {
  // toolchains_llvm pins the LLVM version in tools/cpp.MODULE.bazel.
  // Linux x86_64 (RBE) uses LLVM 15.0.6; macOS uses LLVM 18.1.8.
  // Both are >= 15. If compiled with an older system compiler this fails,
  // proving the hermetic LLVM toolchain is in use.
  EXPECT_GE(__clang_major__, 15)
      << "Compiled with Clang " << __clang_major__
      << " — expected >= 15 from toolchains_llvm";
}
