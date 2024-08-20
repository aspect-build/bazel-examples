#include "lookup.h"

#include <iostream>
#include <string>

#include "sqlite3.h"

namespace Speller {

using namespace std;

void LookupEngine::checkSqlite(int result) {
  if (result != SQLITE_OK) {
    std::string msg = "sqlite3 error, ";
    msg.append(sqlite3_errmsg(database));
    throw runtime_error(msg);
  }
}

LookupEngine::LookupEngine(const std::string &file_name,
                           bool writable) {
  int flags = writable ? SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
                       : SQLITE_OPEN_READONLY;
  checkSqlite(
      sqlite3_open_v2(file_name.c_str(), &database, flags, NULL));

  char *error_msg = 0;
  checkSqlite(sqlite3_exec(
      database, "create TABLE IF NOT EXISTS words (word varchar);",
      nullptr, 0, &error_msg));
  // TODO sqlite3_free(ErrMsg) if an error occurred

  const char **tail = 0;

  checkSqlite(sqlite3_prepare_v3(
      database, "insert into words values (?);", -1, 0,
      &add_statement,
      tail /* OUT: Pointer to unused portion of zSql */
      ));

  checkSqlite(sqlite3_prepare_v3(
      database, "select count(*) from words where word=?;", -1, 0,
      &check_statement,
      tail /* OUT: Pointer to unused portion of zSql */
      ));
}

LookupEngine::~LookupEngine() {
  sqlite3_finalize(add_statement);
  sqlite3_finalize(check_statement);
  sqlite3_close(database);
}

void LookupEngine::AddEntry(const std::string &Word) {
  // A better-written class would return an application-level semantic
  // exception if this is called when not in writable mode, or better
  // yet, have a separate class for writable
  checkSqlite(sqlite3_bind_text(add_statement, 1, Word.c_str(),
                                Word.length(), SQLITE_TRANSIENT));
  sqlite3_step(add_statement);
  checkSqlite(sqlite3_reset(add_statement));
}

int LookupEngine::CheckEntry(const std::string &Word) {
  checkSqlite(sqlite3_bind_text(check_statement, 1, Word.c_str(),
                                Word.length(), SQLITE_TRANSIENT));
  sqlite3_step(check_statement);  // first result row
  int retVal = sqlite3_column_int(check_statement, 0);
  sqlite3_step(check_statement);  // at the end
  checkSqlite(sqlite3_reset(check_statement));

  return retVal;
}

}  // namespace Speller
