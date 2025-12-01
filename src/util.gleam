import gleam/string
import simplifile

pub fn test_input(day: String) -> String {
  let assert Ok(contents) = simplifile.read("inputs/" <> day <> "/test.txt")
  string.trim_end(contents)
}

pub fn real_input(day: String) -> String {
  let assert Ok(contents) = simplifile.read("inputs/" <> day <> "/input.txt")
  string.trim_end(contents)
}
