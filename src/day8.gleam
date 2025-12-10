import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import iv.{type Array}
import util

pub fn main() -> Nil {
  io.println("Day 8")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

type Vector3 {
  Vector3(x: Int, y: Int, z: Int)
}

fn part1() -> Int {
  let vecs =
    util.real_input("08")
    |> string.split("\n")
    |> parse_input
  let initial_circuits =
    vecs |> list.map(fn(v) { set.new() |> set.insert(v) }) |> iv.from_list
  let distances = create_distances(vecs)

  connect(1000, distances, initial_circuits)
  |> iv.map(set.size)
  |> iv.to_list
  |> list.sort(fn(a, b) { int.compare(b, a) })
  |> list.take(3)
  |> list.fold(1, int.multiply)
}

fn part2() -> Int {
  let vecs =
    util.real_input("08")
    |> string.split("\n")
    |> parse_input
  let initial_circuits =
    vecs |> list.map(fn(v) { set.new() |> set.insert(v) }) |> iv.from_list
  let distances = create_distances(vecs)

  connect2(distances, initial_circuits)
}

fn connect(
  iterations: Int,
  distances: List(#(Vector3, Vector3)),
  circuits: Array(Set(Vector3)),
) -> Array(Set(Vector3)) {
  case iterations {
    0 -> circuits
    _ -> {
      let assert [#(a, b), ..rest] = distances

      let assert Ok(index_a) =
        iv.find_index(circuits, fn(s) { set.contains(s, a) })
      let assert Ok(index_b) =
        iv.find_index(circuits, fn(s) { set.contains(s, b) })

      case index_a == index_b {
        True -> connect(iterations - 1, rest, circuits)
        False -> {
          let assert Ok(set_a) = iv.get(circuits, index_a)
          let assert Ok(set_b) = iv.get(circuits, index_b)
          let merged_set = set.union(set_a, set_b)

          let updated_circuits =
            circuits
            |> iv.try_set(index_a, merged_set)
            |> iv.try_delete(index_b)

          connect(iterations - 1, rest, updated_circuits)
        }
      }
    }
  }
}

fn connect2(
  distances: List(#(Vector3, Vector3)),
  circuits: Array(Set(Vector3)),
) -> Int {
  let assert [#(a, b), ..rest] = distances

  let assert Ok(index_a) = iv.find_index(circuits, fn(s) { set.contains(s, a) })
  let assert Ok(index_b) = iv.find_index(circuits, fn(s) { set.contains(s, b) })

  case index_a == index_b {
    True -> connect2(rest, circuits)
    False -> {
      let assert Ok(set_a) = iv.get(circuits, index_a)
      let assert Ok(set_b) = iv.get(circuits, index_b)
      let merged_set = set.union(set_a, set_b)

      let updated_circuits =
        circuits
        |> iv.try_set(index_a, merged_set)
        |> iv.try_delete(index_b)

      case iv.length(updated_circuits) {
        1 -> a.x * b.x
        _ -> connect2(rest, updated_circuits)
      }
    }
  }
}

fn parse_input(lines: List(String)) -> List(Vector3) {
  let assert Ok(vecs) =
    lines
    |> list.map(fn(line) {
      let assert [x_str, y_str, z_str] = string.split(line, on: ",")
      use x <- result.try(int.parse(x_str))
      use y <- result.try(int.parse(y_str))
      use z <- result.map(int.parse(z_str))
      Vector3(x, y, z)
    })
    |> result.all

  vecs
}

fn create_distances(vecs: List(Vector3)) -> List(#(Vector3, Vector3)) {
  vecs
  |> list.combination_pairs
  |> list.map(fn(pair) {
    let #(a, b) = pair
    #(a, b, distance_between(a, b))
  })
  |> list.sort(fn(a, b) {
    let #(_, _, dist_a) = a
    let #(_, _, dist_b) = b
    float.compare(dist_a, dist_b)
  })
  |> list.map(fn(triple) { #(triple.0, triple.1) })
}

fn distance_between(a: Vector3, b: Vector3) -> Float {
  let Vector3(ax, ay, az) = a
  let Vector3(bx, by, bz) = b

  let dx = ax - bx
  let dy = ay - by
  let dz = az - bz

  let assert Ok(res) = int.square_root({ dx * dx } + { dy * dy } + { dz * dz })
  res
}
