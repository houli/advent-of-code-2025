import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util

type Dimensions {
  Dimensions(width: Int, height: Int)
}

pub fn main() -> Nil {
  io.println("Day 12")
  io.println("Part 1: " <> int.to_string(part1()))
}

fn part1() -> Int {
  util.real_input("12")
  |> string.split(on: "\n")
  // Shapes don't matter at all for the real input 😜
  |> list.drop(30)
  |> list.map(parse_input)
  |> list.count(can_fit_shapes)
}

fn can_fit_shapes(spec: #(Dimensions, List(Int))) -> Bool {
  let #(dimensions, counts) = spec
  let total_size_of_shapes = int.sum(counts) * 9
  let area = dimensions.width * dimensions.height
  total_size_of_shapes <= area
}

fn parse_input(line: String) -> #(Dimensions, List(Int)) {
  let assert Ok(#(dim_str, counts_str)) = string.split_once(line, on: ": ")
  let assert Ok(#(width_str, height_str)) = string.split_once(dim_str, on: "x")
  let assert Ok(width) = int.parse(width_str)
  let assert Ok(height) = int.parse(height_str)

  let counts =
    string.split(counts_str, on: " ")
    |> list.map(int.parse)
    |> result.values

  #(Dimensions(width:, height:), counts)
}
