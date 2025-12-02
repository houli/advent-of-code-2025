import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util

pub fn main() -> Nil {
  io.println("Day 1")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

fn part1() -> Int {
  util.real_input("01")
  |> string.split(on: "\n")
  |> parse_lines
  |> list.scan(50, fn(acc, num) { wrapping_add(acc, num) })
  |> list.count(fn(num) { num == 0 })
}

fn part2() -> Int {
  util.real_input("01")
  |> string.split(on: "\n")
  |> parse_lines
  |> list.scan(#(0, 50), fn(acc, num) {
    let old = acc.1
    let res = old + num
    let normalised = case res <= 0, old == 0 {
      True, True -> int.absolute_value(res)
      True, False -> int.absolute_value(res) + 100
      False, _ -> res
    }
    let rotations = normalised / 100
    #(rotations, wrapping_add(old, num))
  })
  |> list.fold(0, fn(acc, x) { acc + x.0 })
}

fn parse_lines(lines: List(String)) -> List(Int) {
  lines
  |> list.map(fn(line) {
    let assert Ok(res) = case line {
      "L" <> num -> int.parse(num) |> result.map(fn(x) { -x })
      "R" <> num -> int.parse(num)
      _ -> Error(Nil)
    }
    res
  })
}

fn wrapping_add(a: Int, b: Int) -> Int {
  let assert Ok(result) = int.modulo({ a + b }, 100)
  result
}
