#include <algorithm>
#include <iostream>
#include <list>
#include <string>

#include "speller/lookup/lookup.h"

using namespace std;

const list<string> common_words{
    "a",     "about", "after", "all",   "also",  "an",      "and",
    "any",   "as",    "at",    "back",  "be",    "because", "but",
    "by",    "can",   "come",  "could", "day",   "do",      "even",
    "first", "for",   "from",  "get",   "give",  "go",      "good",
    "have",  "he",    "her",   "him",   "his",   "how",     "I",
    "if",    "in",    "into",  "it",    "its",   "just",    "know",
    "like",  "look",  "make",  "me",    "most",  "my",      "new",
    "no",    "not",   "now",   "of",    "on",    "one",     "only",
    "or",    "other", "our",   "out",   "over",  "person",  "say",
    "see",   "she",   "so",    "some",  "take",  "than",    "that",
    "the",   "their", "them",  "then",  "there", "these",   "they",
    "think", "this",  "time",  "to",    "two",   "up",      "us",
    "use",   "want",  "way",   "we",    "well",  "what",    "when",
    "which", "who",   "will",  "with",  "work",  "would",   "year",
    "you",   "your",
};

int main(int argc, char **argv) {
  Speller::LookupEngine engine("spell.db", true);

  for_each(common_words.begin(), common_words.end(),
           [&](const string &word) { engine.AddEntry(word); });

  return 0;
}
