import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import range
import util

pub fn main() -> Nil {
  io.println("Day 5")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

fn part1() -> Int {
  let assert [range_strings, ingredient_id_strings] =
    util.real_input("05")
    |> string.split(on: "\n\n")

  let assert Ok(ranges) =
    range_strings
    |> string.split(on: "\n")
    |> list.map(range.from_string)
    |> result.all

  let assert Ok(ingredient_ids) =
    ingredient_id_strings
    |> string.split(on: "\n")
    |> list.map(int.parse)
    |> result.all

  ingredient_ids
  |> list.count(fn(ingredient_id) {
    list.any(ranges, range.contains(_, ingredient_id))
  })
}

fn part2() -> Int {
  let assert [range_strings, _] =
    util.real_input("05")
    |> string.split(on: "\n\n")

  let assert Ok(ranges) =
    range_strings
    |> string.split(on: "\n")
    |> list.map(range.from_string)
    |> result.all

  ranges
  |> range.merge_list
  |> list.fold(0, fn(acc, range) { acc + range.size(range) })
}
