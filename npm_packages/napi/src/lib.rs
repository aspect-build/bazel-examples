#![deny(clippy::all)]

use napi_derive::napi;

#[napi]
pub fn hello(name: String) -> String {
  format!("Hello from Rust code, {}!", name)
}
