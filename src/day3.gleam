import gleam/int
import gleam/io
import gleam/list
import gleam/order.{Eq, Gt, Lt}
import gleam/string
import util

pub fn main() -> Nil {
  io.println("Day 3")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

fn part1() -> Int {
  util.real_input("03")
  |> string.split(on: "\n")
  |> list.map(find_joltage_part_1)
  |> list.fold(0, int.add)
}

fn part2() -> Int {
  util.real_input("03")
  |> string.split(on: "\n")
  |> list.map(find_joltage_part_2)
  |> list.fold(0, int.add)
}

fn find_joltage_part_1(line: String) -> Int {
  find_joltage_loop(line, 0, 2, [])
}

fn find_joltage_part_2(line: String) -> Int {
  find_joltage_loop(line, 0, 12, [])
}

fn find_joltage_loop(
  line: String,
  start_index: Int,
  digits_to_calculate: Int,
  acc: List(String),
) -> Int {
  case digits_to_calculate == 0 {
    True -> {
      let assert Ok(num) = int.parse(string.concat(list.reverse(acc)))
      num
    }
    False -> {
      let len = string.length(line)
      let #(highest_num, highest_num_index) =
        line
        |> string.slice(at_index: start_index, length: len)
        |> highest_n_digits_from_end(digits_to_calculate - 1)
      find_joltage_loop(
        line,
        start_index + highest_num_index + 1,
        digits_to_calculate - 1,
        [highest_num, ..acc],
      )
    }
  }
}

fn highest_n_digits_from_end(line: String, n: Int) -> #(String, Int) {
  line
  |> string.drop_end(up_to: n)
  |> string.to_graphemes
  |> highest
}

fn highest(digits: List(String)) -> #(String, Int) {
  digits
  |> list.index_fold(#("1", 0), fn(acc, digit, index) {
    case string.compare(digit, acc.0) {
      Gt -> #(digit, index)
      Eq -> acc
      Lt -> acc
    }
  })
}
