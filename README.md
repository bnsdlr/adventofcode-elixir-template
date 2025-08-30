# Advent of Code Elixir

Solutions for [Advent of Code](https://adventofcode.com/) in [Elixir](https://elixir-lang.org).

Inspired from [Advent of Code Rust](https://github.com/fspoettel/advent-of-code-rust).

<!--- benchmarking table --->
## Benchmarks

| Year | Day | Part 1 | Part 2 |
| :---: | :---: | :---: | :---: |
| [2025](https://adventofcode.com/2025) | [Day 3](./lib/bin/Y2025/D03.ex) | `-` | `-` |
| [2025](https://adventofcode.com/2025) | [Day 2](./lib/bin/Y2025/D02.ex) | `-` | `-` |
| [2015](https://adventofcode.com/2015) | [Day 1](./lib/bin/Y2015/D01.ex) | `-` | `-` |
| [2025](https://adventofcode.com/2025) | [Day 1](./lib/bin/Y2025/D01.ex) | `-` | `1.0µs` |
<!--- benchmarking table --->

## Template Setup

1. Use [this link](https://github.com/bnsdlr/adventofcode-elixir/generate) to create your repository.
2. Clone the repository to your computer.

> [!IMPORTANT] 
> Make sure not to use the `Logger` module for logging, some tasks like `aoc.test` suppress IO output, this does not work for the Logger module. At least I don't know how...

## Usage

### Scaffolding

Creates files needed to start coding your solution.

```shell
# example: mix aoc.scaffold --year=2025 --day=1
mix aoc.scaffold --year=<year> --day=<day>

# output:
# Created elixir file: lib/bin/Y2025/D01.ex
# Created input file: puzzles/Y2025/D01/input.txt
# Created example file: puzzles/Y2025/D01/example-1.txt
```

To get more examples run `mix help aoc.scaffold`.

This will create the elixir file under `lib/bin/Y<year>/D<day>.ex`, 
one input file at `puzzles/Y<year>/D<day>/input.txt` where you can put the puzzles input 
and a example file to test your code before submitting an anwer lokated at `puzzles/Y<year>/D<day>/example-1.txt`.

> [!TIP]
> You can add more examples by adding an example file with a different number, something like this: `example-2.txt`.
> You can only use integers, no letters...

> [!TIP]
> To specify wich example input your test should use you can change the example option in the generated elixir file.

```elixir
defmodule Bin.Y2025.D01 do
  def part_one(_input) do
    # Code for part one
    nil
  end

  def part_two(_input) do
    # Code for part two
    nil
  end

  def tests do
    [
      # - `part`: Is the atom of the function that will be called from the test.
      # - `result`: Is the expected result returned from the function.
      # - `example`: Specifies which example file to use (../example-<example>.txt).
      [part: :part_one, result: nil, example: 1],
      [part: :part_two, result: nil, example: 1],
      # Feel free to add more tests here.
    ]
  end
end
```

### Testing

Test specified solutions.

```shell
# example: mix aoc.test --year=2025 --day=1
# booth options will default to "all" (will run all solutions found).
mix aoc.test --year=<year> --day=<day>

# output:
# Testing lib/bin/Y2025/D01.ex
# ----------------------------
# Testing part_one
# Part One succeded in 0.003ms
# Testing part_two
# Part One succeded in 0.001ms
```

To get more examples run `mix help aoc.test`.

This task will run all tests specified in the `test/0` function of the solution file.

### Solveing

Solve the specified solution.

```shell
# example: mix aoc.solve --year=2025 --day=1
mix aoc.solve --year=<year> --day=<day>

# output:
# Solve part one.
# Solve part two.
# -------------
# Part One (0.002ms): ✖     # function returned nil
# Part Two (0.002ms): 42
```

More examples can be found by running `mix help aoc.solve`.

This task will run part one and two, and display results. 

### Benchmarking

Benchmark all specified solutions.

> [!TIP]
> Run `mix help aoc.bench` to get a short explanation for the arguments.

```shell
# example: mix aoc.bench --year=2025 --day=1
mix aoc.bench --year=2025 --day=1 --save=<none|missing|all>

# output:
# Benching lib/bin/Y2025/D01.ex
# -----------------------------
# part_one returned nil, skipping.
# part_two: 0.001ms (5)
```
