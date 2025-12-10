import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import util

type Vector2 {
  Vector2(x: Int, y: Int)
}

type Line {
  Line(start: Vector2, end: Vector2)
}

pub fn main() -> Nil {
  io.println("Day 9")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

fn part1() -> Int {
  let assert Ok(res) =
    util.real_input("09")
    |> string.split(on: "\n")
    |> list.map(parse_vector2)
    |> list.combination_pairs
    |> list.map(box_area)
    |> list.max(int.compare)

  res
}

fn part2() -> Int {
  let vecs =
    util.real_input("09")
    |> string.split(on: "\n")
    |> list.map(parse_vector2)
  let assert Ok(first) = list.first(vecs)

  let big_poly_segments =
    list.append(vecs, [first])
    |> list.window_by_2
    |> list.map(fn(pair) {
      let #(start, end) = pair
      Line(start: start, end: end)
    })

  let assert Ok(res) =
    vecs
    |> list.combination_pairs
    |> list.filter(box_can_be_constructed2(big_poly_segments, _))
    |> list.map(box_area)
    |> list.max(int.compare)

  res
}

fn box_area(points: #(Vector2, Vector2)) -> Int {
  let #(first, second) = points
  { int.absolute_value(first.x - second.x) + 1 }
  * { int.absolute_value(first.y - second.y) + 1 }
}

fn box_can_be_constructed2(
  big_poly_segments: List(Line),
  corners: #(Vector2, Vector2),
) -> Bool {
  let #(first, second) = corners
  let min_x = int.min(first.x, second.x)
  let max_x = int.max(first.x, second.x)
  let min_y = int.min(first.y, second.y)
  let max_y = int.max(first.y, second.y)

  list.all(big_poly_segments, fn(big_poly_segment) {
    let poly_min_x = int.min(big_poly_segment.start.x, big_poly_segment.end.x)
    let poly_max_x = int.max(big_poly_segment.start.x, big_poly_segment.end.x)
    let poly_min_y = int.min(big_poly_segment.start.y, big_poly_segment.end.y)
    let poly_max_y = int.max(big_poly_segment.start.y, big_poly_segment.end.y)
    let entirely_inside =
      { min_x < poly_min_x }
      && { poly_max_x < max_x }
      && { min_y < poly_min_y }
      && { poly_min_y < max_y }

    use <- bool.guard(entirely_inside, False)

    let is_horizontal = big_poly_segment.start.y == big_poly_segment.end.y
    let intersect = case is_horizontal {
      True -> {
        // poly_min_y == poly_max_y
        let line_is_between_top_and_bottom_edge_of_rect =
          { min_y < poly_min_y } && { poly_min_y < max_y }
        let line_passes_through_left =
          { poly_min_x < min_x } && { poly_max_x > min_x }
        let line_passes_through_right =
          { poly_min_x < max_x } && { poly_max_x > max_x }

        { line_is_between_top_and_bottom_edge_of_rect }
        && { line_passes_through_left || line_passes_through_right }
      }
      False -> {
        // poly_min_x == poly_max_x
        let line_is_between_left_and_right_edge_of_rect =
          { min_x < poly_min_x } && { poly_min_x < max_x }
        let line_passes_through_bottom =
          { poly_min_y < min_y } && { poly_max_y > min_y }
        let line_passes_through_top =
          { poly_min_y < max_y } && { poly_max_y > max_y }

        { line_is_between_left_and_right_edge_of_rect }
        && { line_passes_through_bottom || line_passes_through_top }
      }
    }
    !intersect
  })
}

fn parse_vector2(line: String) -> Vector2 {
  let assert Ok(#(x_str, y_str)) = string.split_once(line, on: ",")
  let assert Ok(x) = int.parse(x_str)
  let assert Ok(y) = int.parse(y_str)
  Vector2(x: x, y: y)
}
