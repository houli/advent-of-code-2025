import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import util

type Graph =
  Dict(String, List(String))

pub fn main() -> Nil {
  io.println("Day 11")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

fn part1() -> Int {
  util.real_input("11")
  |> string.split(on: "\n")
  |> build_graph
  |> count_paths_to_out
}

fn part2() -> Int {
  util.real_input("11")
  |> string.split(on: "\n")
  |> build_graph
  |> count_paths_to_out_with_extra
}

fn count_paths_to_out(graph: Graph) -> Int {
  let assert Ok(start_connections) = dict.get(graph, "you")
  count_paths_to_out_loop(graph, start_connections)
}

fn count_paths_to_out_loop(graph: Graph, connections: List(String)) -> Int {
  connections
  |> list.map(fn(connection) {
    case connection {
      "out" -> 1
      _ -> {
        let assert Ok(new_connections) = dict.get(graph, connection)
        count_paths_to_out_loop(graph, new_connections)
      }
    }
  })
  |> int.sum
}

fn count_paths_to_out_with_extra(graph: Graph) -> Int {
  let assert Ok(start_connections) = dict.get(graph, "svr")
  let res =
    count_paths_to_out_with_extra_loop(
      graph,
      start_connections,
      False,
      False,
      dict.new(),
    )
  res.0
}

fn count_paths_to_out_with_extra_loop(
  graph: Graph,
  connections: List(String),
  seen_dac: Bool,
  seen_fft: Bool,
  cache: Dict(#(String, Bool, Bool), Int),
) -> #(Int, Dict(#(String, Bool, Bool), Int)) {
  connections
  |> list.fold(#(0, cache), fn(acc, connection) {
    let #(current_count, current_cache) = acc
    let cache_key = #(connection, seen_dac, seen_fft)

    use <- result.lazy_unwrap(
      dict.get(current_cache, cache_key)
      |> result.map(fn(count) { #(current_count + count, cache) }),
    )

    let #(count, new_cache) = case connection {
      "out" -> {
        let count = case seen_dac && seen_fft {
          True -> 1
          False -> 0
        }
        #(count, current_cache)
      }
      _ -> {
        let assert Ok(new_connections) = dict.get(graph, connection)
        let seen_dac_new = seen_dac || connection == "dac"
        let seen_fft_new = seen_fft || connection == "fft"
        count_paths_to_out_with_extra_loop(
          graph,
          new_connections,
          seen_dac_new,
          seen_fft_new,
          current_cache,
        )
      }
    }
    #(current_count + count, dict.insert(new_cache, cache_key, count))
  })
}

fn build_graph(lines: List(String)) -> Graph {
  lines
  |> list.fold(dict.new(), fn(acc, line) {
    case string.split_once(line, ": ") {
      Ok(#(node, connections_str)) -> {
        let connections = string.split(connections_str, " ")
        dict.insert(acc, node, connections)
      }
      _ -> acc
    }
  })
}
