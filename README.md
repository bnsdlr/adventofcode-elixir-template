# Advent of Code Elixir

Solutions for [Advent of Code](https://adventofcode.com/) in [Elixir](https://elixir-lang.org).

Inspired from [Advent of Code Rust](https://github.com/fspoettel/advent-of-code-rust).

> [!IMPORTANT]
> [DON'T make the advent of code puzzle inputs public](https://adventofcode.com/2024/about#:~:text=Can%20I%20copy,it%20something%20similar.). Do one of the following:
> 1. Make your repository private.
> 2. Or add those lines to your `.gitignore` file:
> ```shell
> input.txt
> example-*.txt
> ```

<!--- benchmarking table --->
## Benchmarks

| Year | Day | Part 1 | Part 2 |
| :---: | :---: | :---: | :---: |
<!--- benchmarking table --->

## Template Setup

1. Use [this link](https://github.com/bnsdlr/adventofcode-elixir-template/generate) to create your repository.
2. Clone the repository to your computer.
3. Use [`mix aoc.scaffold`](https://github.com/bnsdlr/adventofcode-elixir?tab=readme-ov-file#scaffolding) and start coding!!!

> [!IMPORTANT] 
> Make sure not to use the `Logger` module for logging, some tasks like `aoc.test` suppress IO output, this does work for the Logger module, but then the output wont be in the right order...

## Usage

### Arguments

You can pass arguments in three different ways.

1. As key value pair: `--<key>=<value>`
2. As key only, will set the value to `true`: `--<key>`
3. As value only, this will try to match values to a key: `<value>`

    E.g. if you pass `2025` will know it is a `year` because it has 4 digits and is in range from `2000` to `2099`.
    Days can also be recognized because they are 1 or 2 digits and are in range from `1` to `25`.

> [!TIP]
> You can get more information about `arguments` and more examples by running: `mix help aoc.<command>`.

### Scaffolding

```shell
# example: mix aoc.scaffold 2025 1
mix aoc.scaffold --year=<year> --day=<day>

# output:
# Created elixir file: lib/bin/Y2025/D01.ex
# Created input file: puzzles/Y2025/D01/input.txt
# Created example file: puzzles/Y2025/D01/example-1.txt
# Created .keep file: data/Y2025/D01/.keep
```

> [!TIP]
> You can add more examples by adding an example file with a different number, something like this: `example-2.txt`.
> You can only use integers, no letters...

> [!TIP]
> To specify wich example input your test should use you can change the example option in the generated elixir file.

Read the comments.

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

```shell
# example: mix aoc.test 2025 1
mix aoc.test --year=<year> --day=<day>

# output:
# Testing lib/bin/Y2025/D01.ex
# ----------------------------
# Testing part_one
# Part One succeded in 0.003ms
# Testing part_two
# Part One succeded in 0.001ms
```

This task will run all tests specified in the `tests/0` function of the solution file.

### Solving

```shell
# example: mix aoc.solve 2025 1
mix aoc.solve --year=<year> --day=<day>

# output:
# Solve part one.
# Solve part two.
# -------------
# Part One (0.002ms): ✖		 # function returned nil
# Part Two (0.002ms): 42
```

This task will run part one and two, and display the results. 

### Benchmarking

```shell
# example: mix aoc.bench 2025 1
mix aoc.bench --year=2025 --day=1

# output:
# Benching lib/bin/Y2025/D01.ex
# -----------------------------
# part_one returned nil, skipping.
# part_two: 0.001ms (5)
```
