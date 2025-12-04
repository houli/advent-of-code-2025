import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import iv.{type Array}
import util

pub fn main() -> Nil {
  io.println("Day 4")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

fn part1() -> Int {
  let mat =
    util.real_input("04")
    |> string.split(on: "\n")
    |> create_array

  iv.index_map(mat, fn(arr, y) {
    iv.index_map(arr, fn(val, x) {
      #(#(x, y), val, list.fold(adjacent_nums(mat, #(x, y)), 0, int.add))
    })
  })
  |> rolls_accessible
  |> iv.length
}

fn part2() -> Int {
  let mat =
    util.real_input("04")
    |> string.split(on: "\n")
    |> create_array

  part2_loop(mat, 0)
}

fn part2_loop(mat: Array(Array(Int)), acc: Int) -> Int {
  let transformed =
    iv.index_map(mat, fn(arr, y) {
      iv.index_map(arr, fn(val, x) {
        #(#(x, y), val, list.fold(adjacent_nums(mat, #(x, y)), 0, int.add))
      })
    })

  let accessible = rolls_accessible(transformed)
  let points_to_remove = accessible |> iv.map(fn(x) { x.0 })
  let new_mat = remove_accessible(mat, points_to_remove)
  let count = iv.length(accessible)
  case count {
    0 -> acc
    num -> part2_loop(new_mat, acc + num)
  }
}

fn remove_accessible(
  mat: Array(Array(Int)),
  points_to_remove: Array(#(Int, Int)),
) -> Array(Array(Int)) {
  mat
  |> iv.index_map(fn(arr, y) {
    iv.index_map(arr, fn(val, x) {
      case iv.contains(points_to_remove, #(x, y)) {
        True -> 0
        False -> val
      }
    })
  })
}

fn rolls_accessible(
  transformed: Array(Array(#(#(Int, Int), Int, Int))),
) -> Array(#(#(Int, Int), Int, Int)) {
  transformed
  |> iv.flatten
  |> iv.filter(fn(x) { x.1 == 1 && x.2 < 4 })
}

fn adjacent_nums(mat: Array(Array(Int)), point: #(Int, Int)) -> List(Int) {
  let steps = [-1, 0, 1]
  // Ignore the current point
  let offsets =
    list.flat_map(steps, fn(x) { list.map(steps, fn(y) { #(x, y) }) })
    |> list.filter(fn(step) { step != #(0, 0) })
  offsets
  |> list.map(fn(offset) {
    let y = point.1 + offset.1
    let x = point.0 + offset.0
    use arr <- result.try(iv.get(mat, y))
    use val <- result.try(iv.get(arr, x))
    Ok(val)
  })
  |> list.map(result.unwrap(_, 0))
}

fn create_array(lines: List(String)) -> Array(Array(Int)) {
  lines
  |> list.map(fn(line) {
    string.to_graphemes(line)
    |> list.map(fn(char) {
      let assert Ok(n) = case char {
        "." -> Ok(0)
        "@" -> Ok(1)
        _ -> Error(Nil)
      }
      n
    })
    |> iv.from_list
  })
  |> iv.from_list
}
