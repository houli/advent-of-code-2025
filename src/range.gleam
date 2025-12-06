import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub opaque type Range {
  Range(start: Int, end: Int)
}

pub fn size(range: Range) -> Int {
  { range.end - range.start } + 1
}

pub fn new(first: Int, second: Int) -> Range {
  case first >= second {
    True -> Range(start: second, end: first)
    False -> Range(start: first, end: second)
  }
}

pub fn from_string(string: String) -> Result(Range, Nil) {
  use #(first_str, second_str) <- result.try(string.split_once(string, on: "-"))
  use first <- result.try(int.parse(first_str))
  use second <- result.map(int.parse(second_str))

  new(first, second)
}

pub fn to_list(range: Range) -> List(Int) {
  to_list_loop(range.end, range.start, [])
}

fn to_list_loop(current: Int, start: Int, acc: List(Int)) -> List(Int) {
  case current < start {
    True -> acc
    False -> to_list_loop(current - 1, start, [current, ..acc])
  }
}

pub fn contains(range: Range, num: Int) -> Bool {
  num >= range.start && num <= range.end
}

pub fn merge_list(ranges: List(Range)) -> List(Range) {
  let sorted_ranges =
    ranges
    |> list.sort(fn(a, b) { int.compare(a.start, b.start) })
  merge_list_loop(sorted_ranges, [])
}

fn merge_list_loop(ranges: List(Range), acc: List(Range)) -> List(Range) {
  case ranges {
    [] -> acc
    [head, ..tail] -> {
      case acc {
        [] -> merge_list_loop(tail, [head])
        [last_merged, ..rest] -> {
          case is_disjoint(head, from: last_merged) {
            True -> merge_list_loop(tail, [head, last_merged, ..rest])
            False -> {
              let merged_range =
                Range(
                  int.min(last_merged.start, head.start),
                  int.max(last_merged.end, head.end),
                )
              merge_list_loop(tail, [merged_range, ..rest])
            }
          }
        }
      }
    }
  }
}

pub fn is_disjoint(range: Range, from other: Range) -> Bool {
  range.end < other.start || other.end < range.start
}
