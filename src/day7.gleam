import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import iv
import util

pub fn main() -> Nil {
  io.println("Day 7")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

type Point {
  Point(x: Int, y: Int)
}

fn part1() -> Int {
  let lines = util.real_input("07") |> string.split(on: "\n")
  let max_y = list.length(lines) - 1
  let #(start, splitters) = parse_input(lines)

  splitters_hit(max_y, start, splitters)
}

fn part2() -> Int {
  let lines = util.real_input("07") |> string.split(on: "\n")
  let max_y = list.length(lines) - 1
  let #(start, splitters) = parse_input(lines)

  timeline_count(max_y, start, splitters)
}

fn parse_input(lines: List(String)) -> #(Point, Set(Point)) {
  let assert Ok(start) =
    lines
    |> list.first()
    |> result.map(fn(line) {
      line
      |> string.to_graphemes
      |> iv.from_list
      |> iv.find_index(fn(c) { c == "S" })
      |> result.map(fn(x) { Point(x: x, y: 0) })
    })
    |> result.flatten

  let splitters =
    lines
    |> list.index_map(fn(line, y) {
      line
      |> string.to_graphemes
      |> list.index_map(fn(c, x) {
        case c {
          "^" -> Ok(Point(x, y))
          _ -> Error(Nil)
        }
      })
    })
    |> list.flatten
    |> result.values
    |> set.from_list

  #(start, splitters)
}

fn splitters_hit(max_y: Int, start_point: Point, splitters: Set(Point)) -> Int {
  let start_set = set.new() |> set.insert(start_point)
  splitters_hit_loop(max_y, 0, start_set, splitters, 0)
}

fn splitters_hit_loop(
  max_y: Int,
  current_y: Int,
  points: Set(Point),
  splitters: Set(Point),
  splitters_hit_count: Int,
) -> Int {
  case current_y == max_y {
    True -> splitters_hit_count
    False -> {
      let next_points_including_hits =
        points
        |> set.map(fn(point) { Point(x: point.x, y: point.y + 1) })
      let splitters_hit_next_line =
        next_points_including_hits |> set.intersection(splitters)
      let points_produced_from_splitters =
        splitters_hit_next_line
        |> set.to_list
        |> list.map(fn(point) {
          [Point(x: point.x - 1, y: point.y), Point(x: point.x + 1, y: point.y)]
        })
        |> list.flatten
        |> set.from_list
      let next_points =
        next_points_including_hits
        |> set.difference(splitters_hit_next_line)
        |> set.union(points_produced_from_splitters)

      splitters_hit_loop(
        max_y,
        current_y + 1,
        next_points,
        splitters,
        splitters_hit_count + set.size(splitters_hit_next_line),
      )
    }
  }
}

fn timeline_count(max_y: Int, point: Point, splitters: Set(Point)) -> Int {
  let res = timeline_count_loop(max_y, point, splitters, dict.new())
  res.0
}

fn timeline_count_loop(
  max_y: Int,
  point: Point,
  splitters: Set(Point),
  cache: Dict(Point, Int),
) -> #(Int, Dict(Point, Int)) {
  use <- result.lazy_unwrap(
    dict.get(cache, point)
    |> result.map(fn(num) { #(num, cache) }),
  )

  case point.y == max_y {
    True -> #(1, dict.insert(cache, point, 1))
    False -> {
      let next = Point(x: point.x, y: point.y + 1)
      case set.contains(splitters, next) {
        True -> {
          let left = Point(x: next.x - 1, y: next.y)
          let right = Point(x: next.x + 1, y: next.y)
          let #(left_res, cache) =
            timeline_count_loop(max_y, left, splitters, cache)
          let #(right_res, cache) =
            timeline_count_loop(max_y, right, splitters, cache)
          let total = left_res + right_res
          #(total, dict.insert(cache, point, total))
        }
        False -> {
          let #(res, cache) = timeline_count_loop(max_y, next, splitters, cache)
          #(res, dict.insert(cache, point, res))
        }
      }
    }
  }
}
