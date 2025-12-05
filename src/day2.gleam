import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import range
import util

pub fn main() -> Nil {
  io.println("Day 2")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

fn part1() -> Int {
  let assert Ok(ranges) =
    util.real_input("02")
    |> string.split(on: ",")
    |> list.map(range.from_string)
    |> result.all

  ranges
  |> list.flat_map(range.to_list)
  |> list.filter(is_invalid_part_1)
  |> list.fold(0, int.add)
}

fn part2() -> Int {
  let assert Ok(ranges) =
    util.real_input("02")
    |> string.split(on: ",")
    |> list.map(range.from_string)
    |> result.all

  ranges
  |> list.flat_map(range.to_list)
  |> list.filter(is_invalid_part_2)
  |> list.fold(0, int.add)
}

fn is_invalid_part_1(num: Int) -> Bool {
  let num_str = int.to_string(num)
  let len = string.length(num_str)
  let is_even_length = int.is_even(len)

  let first_half = string.slice(num_str, 0, { len / 2 })
  let second_half = string.slice(num_str, len / 2, { len / 2 } + 1)
  let halves_are_equal = first_half == second_half

  is_even_length && halves_are_equal
}

fn is_invalid_part_2(num: Int) -> Bool {
  let num_str = int.to_string(num)
  let len = string.length(num_str)

  list.any(digit_patterns(num_str), fn(pattern) {
    let times_to_repeat = len / string.length(pattern)
    num_str == string.repeat(pattern, times: times_to_repeat)
  })
}

fn digit_patterns(num_str: String) -> List(String) {
  digit_patterns_loop(num_str, string.length(num_str), 1, [])
}

fn digit_patterns_loop(
  num_str: String,
  length: Int,
  digits_count: Int,
  acc: List(String),
) -> List(String) {
  case digits_count > length / 2 {
    True -> acc
    False -> {
      let divides_evenly = length % digits_count == 0
      case divides_evenly {
        True -> {
          let current = string.slice(num_str, 0, digits_count)
          digit_patterns_loop(num_str, length, digits_count + 1, [
            current,
            ..acc
          ])
        }
        False -> digit_patterns_loop(num_str, length, digits_count + 1, acc)
      }
    }
  }
}
