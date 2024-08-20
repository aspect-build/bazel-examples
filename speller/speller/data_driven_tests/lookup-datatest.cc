#include <algorithm>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <list>
#include <string>

#include "gtest/gtest.h"
#include "speller/lookup/lookup.h"
#include "third_party/nlohmann-json/json.hpp"

using namespace Speller;
using namespace std;
using json = nlohmann::json;

struct test_config {
  list<string> words;
  string testWord;
  int expected;
};

void from_json(const json& j, test_config& p) {
  j.at("words").get_to(p.words);
  j.at("testWord").get_to(p.testWord);
  j.at("expected").get_to(p.expected);
}

TEST(LookupEngineTest, DataDriven) {
  if (const char* env_config_file = std::getenv("TEST_CONFIG_FILE")) {
    string config_file = env_config_file;

    ifstream json_stream(config_file);
    json j;
    json_stream >> j;
    auto config = j.get<test_config>();

    LookupEngine engine(":memory:", true);

    for_each(config.words.begin(), config.words.end(),
             [&](const string& word) { engine.AddEntry(word); });

    EXPECT_EQ(config.expected, engine.CheckEntry(config.testWord));
  } else {
    FAIL() << "missing TEST_CONFIG_FILE";
  }
}
