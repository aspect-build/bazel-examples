#include "speller/lookup/lookup.h"

#include <filesystem>
#include <iostream>
#include <string>

#include "gtest/gtest.h"

// Some people advocate keeping GoogleTest tests in the default
// namespace, for shorter test code files and because some test
// machinery expects globaly unique test names anyway.

using namespace Speller;

TEST(LookupEngineTest, CreateAndDestroy) {
  LookupEngine engine(":memory:", true);
  // No exception, no problem
}

TEST(LookupEngineTest, PersistsFile) {
  std::string tempFileName = "testdb.db";
  {
    LookupEngine engine(tempFileName, true);
    engine.AddEntry("Bazel");
  }
  std::filesystem::path f{tempFileName};
  EXPECT_TRUE(std::filesystem::exists(f));
  std::filesystem::remove(f);
}

TEST(LookupEngineTest, AddWord) {
  LookupEngine engine(":memory:", true);
  EXPECT_EQ(engine.CheckEntry("Bazel"), 0);
  engine.AddEntry("Bazel");
  EXPECT_EQ(engine.CheckEntry("Bazel"), 1);
}

TEST(LookupEngineTest, AddingWords) {
  LookupEngine engine(":memory:", true);
  engine.AddEntry("air");
  engine.AddEntry("water");
  engine.AddEntry("fire");
  EXPECT_EQ(engine.CheckEntry("air"), 1);
  EXPECT_EQ(engine.CheckEntry("water"), 1);
  EXPECT_EQ(engine.CheckEntry("fire"), 1);
  EXPECT_EQ(engine.CheckEntry("dfbubu"), 0);
}
