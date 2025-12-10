import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import shellout
import simplifile
import temporary
import util

type Machine {
  Machine(
    target_lights: List(Bool),
    buttons: List(List(Int)),
    target_joltages: List(Int),
  )
}

pub fn main() -> Nil {
  io.println("Day 10")
  io.println("Part 1: " <> int.to_string(part1()))
  io.println("Part 2: " <> int.to_string(part2()))
}

fn part1() -> Int {
  util.real_input("10")
  |> string.split(on: "\n")
  |> list.map(parse_machine)
  |> list.map(fn(machine) {
    let assert Ok(length_of_sequence) =
      machine.buttons
      |> powerset
      |> list.filter(fn(presses) {
        let press_counts =
          presses
          |> list.flatten
          |> list.group(function.identity)
          |> dict.map_values(fn(_k, v) { list.length(v) })

        list.index_map(machine.target_lights, fn(light, i) {
          let count = result.unwrap(dict.get(press_counts, i), 0)
          { count % 2 == 1 } == light
        })
        |> list.all(function.identity)
      })
      |> list.map(list.length)
      |> list.sort(int.compare)
      |> list.first

    length_of_sequence
  })
  |> int.sum
}

fn part2() -> Int {
  util.real_input("10")
  |> string.split(on: "\n")
  |> list.map(parse_machine)
  |> list.map(build_z3_program)
  |> list.map(eval_z3_program)
  |> int.sum
}

fn eval_z3_program(program: String) -> Int {
  let assert Ok(res) = {
    use file <- temporary.create(temporary.file())
    let assert Ok(_) = simplifile.write(file, program)
    let assert Ok(z3_output) =
      shellout.command("z3", with: [file], in: ".", opt: [])
    let assert Ok(#(_, num_str)) =
      z3_output
      |> string.split_once(on: "\n")
    let assert Ok(num) = int.parse(string.trim(num_str))
    num
  }
  res
}

fn build_z3_program(machine: Machine) -> String {
  let z3_button_press_variables =
    machine.buttons
    |> list.index_map(fn(_, i) {
      "(declare-const b" <> int.to_string(i) <> " Int)"
    })

  let z3_presses_greater_than_zero_asserts =
    machine.buttons
    |> list.index_map(fn(_, i) { "(assert (>= b" <> int.to_string(i) <> " 0))" })

  let z3_sum_asserts =
    machine.target_joltages
    |> list.index_map(fn(target_joltage, joltage_index) {
      let button_numbers_containing_index =
        machine.buttons
        |> list.index_map(fn(button, button_index) {
          case list.contains(button, joltage_index) {
            True -> Ok(button_index)
            False -> Error(Nil)
          }
        })
        |> result.values
      let button_sum_str =
        button_numbers_containing_index
        |> list.map(fn(num) { "b" <> int.to_string(num) })
        |> string.join(" ")

      "(assert (= (+ "
      <> button_sum_str
      <> ") "
      <> int.to_string(target_joltage)
      <> "))"
    })

  let button_sum_str =
    machine.buttons
    |> list.index_map(fn(_, i) { "b" <> int.to_string(i) })
    |> string.join(" ")
  let z3_total_fun = "(define-fun total () Int (+ " <> button_sum_str <> "))"

  [
    z3_button_press_variables,
    z3_presses_greater_than_zero_asserts,
    z3_sum_asserts,
    [
      z3_total_fun,
      "(minimize total)",
      "(check-sat)",
      "(eval total)",
    ],
  ]
  |> list.flatten
  |> string.join("\n")
}

fn powerset(list: List(a)) -> List(List(a)) {
  case list {
    [] -> [[]]
    [head, ..tail] -> {
      powerset(tail)
      |> list.flat_map(fn(combo) { [combo, [head, ..combo]] })
    }
  }
}

fn parse_machine(line: String) -> Machine {
  let assert Ok(#(target_str, rest)) = string.split_once(line, on: "]")
  let target_lights =
    target_str
    |> string.drop_start(1)
    |> string.to_graphemes
    |> list.map(fn(c) {
      case c {
        "#" -> Ok(True)
        "." -> Ok(False)
        _ -> Error(Nil)
      }
    })
    |> result.values

  let assert Ok(#(button_str, joltage_rest)) = string.split_once(rest, on: "{")
  let buttons =
    button_str
    |> string.trim
    |> string.replace(each: "(", with: "")
    |> string.replace(each: ")", with: "")
    |> string.split(on: " ")
    |> list.map(fn(str) {
      str
      |> string.split(on: ",")
      |> list.map(int.parse)
      |> result.values
    })

  let target_joltages =
    joltage_rest
    |> string.drop_end(1)
    |> string.split(on: ",")
    |> list.map(int.parse)
    |> result.values

  Machine(target_lights:, buttons:, target_joltages:)
}
