import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import iv.{type Array}
import range
import util

pub fn main() -> Nil {
  io.println("Day 6")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

fn part1() -> Int {
  let lines =
    util.real_input("06")
    |> string.split(on: "\n")
    |> iv.from_list

  let numbers = lines |> iv.drop_last(1) |> number_lines_to_mat
  let assert Ok(ops) = lines |> iv.last |> result.map(parse_ops)

  iv.index_map(ops, fn(op, index) {
    iv.map(numbers, fn(num_arr) {
      let assert Ok(num) = iv.get(num_arr, index)
      num
    })
    |> iv.to_list
    |> op
  })
  |> iv.to_list
  |> int.sum
}

fn part2() -> Int {
  let lines =
    util.test_input("06")
    |> string.split(on: "\n")
    |> iv.from_list

  let numbers = lines |> iv.drop_last(1) |> number_lines_to_mat_funky
  let assert Ok(ops) = lines |> iv.last |> result.map(parse_ops)

  iv.index_map(numbers, fn(num_arr, index) {
    let assert Ok(op) = iv.get(ops, index)

    op(iv.to_list(num_arr))
  })
  |> iv.to_list
  |> int.sum
}

fn number_lines_to_mat(lines: Array(String)) -> Array(Array(Int)) {
  lines
  |> iv.map(fn(line) {
    let assert Ok(nums) =
      line
      |> string_split_variable_space
      |> list.map(int.parse)
      |> result.all

    iv.from_list(nums)
  })
}

fn number_lines_to_mat_funky(lines: Array(String)) -> Array(Array(Int)) {
  let assert Ok(line) = iv.first(lines)
  let indexes =
    range.new(0, string.length(line) - 1)
    |> range.to_list

  let as_graphemes =
    lines
    |> iv.map(fn(line) { string.to_graphemes(line) |> iv.from_list })

  indexes
  |> list.map(fn(index) {
    as_graphemes
    |> iv.map(fn(chars) {
      let assert Ok(char) = iv.get(chars, index)
      char
    })
    |> iv.to_list
    |> string.concat
    |> string.trim
  })
  |> list.chunk(fn(x) { x != "" })
  |> list.filter(fn(chunk) { chunk != [""] })
  |> list.map(fn(chunk) {
    chunk
    |> list.map(fn(num_str) {
      let assert Ok(num) = int.parse(num_str)
      num
    })
    |> iv.from_list
  })
  |> iv.from_list
}

fn parse_ops(ops_string: String) -> Array(fn(List(Int)) -> Int) {
  ops_string
  |> string_split_variable_space
  |> iv.from_list
  |> iv.map(fn(op_str) {
    case op_str {
      "+" -> int.sum
      "*" -> int.product
      _ -> panic as "Unknown op"
    }
  })
}

fn string_split_variable_space(str: String) -> List(String) {
  str
  |> string.trim
  |> string.split(on: " ")
  |> list.filter(fn(x) { x != "" })
}
