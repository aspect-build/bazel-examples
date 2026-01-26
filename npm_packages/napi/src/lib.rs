use napi_derive::napi;
// Unused import, clippy will remove
use std::collections::HashMap;

#[napi]
pub fn hello(name: String) -> String {
  format!("Hello from Rust code, {}!", name)
}
