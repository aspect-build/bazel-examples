#ifndef INCLUDE_LOOKUP_HPP
#define INCLUDE_LOOKUP_HPP

#include <set>
#include <string>

#include "sqlite3.h"

namespace Speller {

class LookupEngine {
  sqlite3 *database;
  sqlite3_stmt *add_statement;
  sqlite3_stmt *check_statement;
  void checkSqlite(int rc);

 public:
  LookupEngine(const std::string &file_name, bool writable);

  virtual ~LookupEngine();

  void AddEntry(const std::string &word);

  int CheckEntry(const std::string &word);
};

}  // namespace Speller

#endif
