defmodule Mix.Tasks.Aoc.Solve do
	@moduledoc """
	Solve advent of code solutions.

	## Examples

		$ mix aoc.solve --year=2025 --day=24
		...
		Solve part one.
		...
		Solve part two.
		---------
		Part One (<time>): <result>
		Part Two (<time>): <result>
	"""

	use Mix.Task

	@impl Mix.Task
	def run(args) do
		%{"year" => year, "day" => day} =
			AOC.Args.parse(args)
			|> AOC.Args.apply_config!(arg_config())

		input_file = AOC.Path.get(:puzzle, [year, day, :input])

		with true <- File.exists?(input_file),
				 input <- File.read!(input_file),
				 {:ok, mod} <- AOC.Mod.get(year, day) do
			IO.puts("\e[32mSolve part one.\e[0m")
			part_one = AOC.time(fn -> apply(mod, :part_one, [input]) end)
			IO.puts("\e[32mSolve part two.\e[0m")
			part_two = AOC.time(fn -> apply(mod, :part_two, [input]) end)

			IO.puts("-------------")
			display_result("One", part_one)
			display_result("Two", part_two)
		else
			false -> AOC.log_err!("Input file (#{input_file}) does not exist.")
			{:error, reason} -> AOC.log_err!(reason)
		end
	end

	def display_result(part, {μs, result}) when is_binary(part) do
		result = if result == nil, do: "\e[31m✖", else: "\e[33m#{result}"
		IO.puts("Part #{part} (\e[3;35m#{μs / 1000}ms\e[0m): #{result}\e[0m")
	end

	def arg_config do
		# TODO: add silent option
		%{
			"year" => %AOC.ArgConfig{
				required: true,
				validation_fn: &AOC.Year.validate(&1),
				format_fn: &AOC.Year.new!(&1)
			},
			"day" => %AOC.ArgConfig{
				required: true,
				validation_fn: &AOC.Day.validate(&1),
				format_fn: &AOC.Day.new!(&1)
			}
		}
	end
end
