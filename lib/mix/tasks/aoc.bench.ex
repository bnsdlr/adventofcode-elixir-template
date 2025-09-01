defmodule Mix.Tasks.Aoc.Bench do
	@moduledoc """
	Benchmark advent of code solutions.

	## Options

	- `save`: Will only execute effected solutions, defaults to `missing`.
	rose-pine	- `all`: Save all benchmarks to README.md.
		- `missing`: Save missing benchmarks to README.md.
		- `none`: Save no benchmarks but run all solutions.
	- `year`: The year of the solution, can be `all` (dafaults to `all`)
	- `day`: The day of the solution, can be `all` (dafaults to `all`)
	- `times`: How often a part is run, to calculate the average.
		It's a list split by commas, key and value are split by colon.
		Keys are:
		- `part_one` or `one` or `o`: for part_one
		- `part_two` or `two` or `t`: for part_two
		Format: <key>:<value>,<key>:<value>
		Default value is 5 for booth.

	## Examples

	Bench all solutions but save none.

		$ mix aoc.bench --save=none

	Bench all solutions and save `missing` benchmarks.

		$ mix aoc.bench

	Bench all solutions in specified `year` and save `all` benchmarks.

		$ mix aoc.bench --year=2025 --save=all

	Bench all solutions, and run each part 10 `times` to calculate its average.

		$ mix aoc.bench --times=10
	"""

	use Mix.Task

	@impl Mix.Task
	def run(args) do
		%{"save" => save, "year" => year, "day" => day, "times" => times} =
			AOC.Args.parse(args)
			|> AOC.Args.apply_config!(arg_config())

		[part_one: part_one_times, part_two: part_two_times] = times

		old_benchmarks = extract_benchmarks!()

		solutions = AOC.Path.Solution.get!(year, day)

		solutions =
			case save do
				"none" ->
					solutions

				"all" ->
					solutions

				"missing" ->
					Enum.filter(solutions, fn sol ->
						Enum.any?(
							old_benchmarks,
							fn b -> b.year != elem(sol, 0) or b.day != elem(sol, 1) end
						)
					end)

				_ ->
					AOC.log_err!("Unknown save value: #{save}.")
			end

		new_benchmarks =
			for {year, day} <- Enum.sort_by(solutions, &"#{elem(&1, 0)}#{elem(&1, 1)}") do
				solution_file = AOC.Path.get(:solution, [year, day])
				IO.puts("\e[34mBenching \e[36m#{solution_file}\e[0m")
				IO.puts("\e[36m-----------------------------\e[0m")

				input_file = AOC.Path.get(:puzzle, [year, day, :input])

				benchmark =
					if File.exists?(input_file) do
						input = File.read!(input_file)

						case AOC.Mod.get(year, day) do
							{:ok, mod} ->
								benchs = bench(mod, input, part_one: part_one_times, part_two: part_two_times)

								benchs =
									Enum.reduce(benchs, [], fn {part, micros}, acc ->
										elem(
											Keyword.get_and_update(acc, part, fn current ->
												if current == nil,
													do: {current, [micros]},
													else: {current, [micros | current]}
											end),
											1
										)
									end)

								benchmarks =
									for {part, times} <- benchs do
										length = length(times)
										avg = Enum.sum(times) / length
										IO.puts("\e[2K#{part}: #{AOC.format_micros(avg)} (#{length})")
										{part, avg}
									end

								{:ok, AOC.BenchTiming.from(year, day, benchmarks)}

							{:error, reason} ->
								AOC.log_err(reason)
								{:error, reason}
						end
					else
						reason = "Could not locate input file: \e[36m#{input_file}\e[0m"
						AOC.log_err(reason)
						{:error, reason}
					end

				IO.puts("")
				benchmark
			end

		new_benchmarks = for {:ok, benchs} <- new_benchmarks, do: benchs

		if save != "none" and not Enum.empty?(new_benchmarks) do
			benchmarks = merge_benchmarks(old_benchmarks, new_benchmarks)

			set_benchmark_table!(benchmarks)
		end
	end

	@doc """
	Merges `old` and `new` benchmarks.

	Benchmarks in `old` maybe overwritten by benchmarks in `new`.
	"""
	def merge_benchmarks(old, new)

	def merge_benchmarks(old, []) when is_list(old) do
		old
	end

	def merge_benchmarks(old, new) when is_list(old) and is_list(new) do
		[first | new] = new

		{state, index} =
			Enum.reduce_while(old, {:cont, 0}, fn b, {_, count} ->
				if b.year == first.year and b.day == first.day,
					do: {:halt, {:halt, count}},
					else: {:cont, {:cont, count + 1}}
			end)

		old =
			if state == :halt do
				List.replace_at(old, index, first)
			else
				[first | old]
			end

		merge_benchmarks(old, new)
	end

	def bench(mod, input, parts), do: bench(mod, input, [], parts)

	def bench(_mod, _input, results, []), do: results

	def bench(mod, input, results, parts) when is_list(parts) do
		[{part, times} | parts] = parts

		if times > 0 do
			IO.puts("\e[2KBenching #{part}: #{times}\e[1A")
			{{micros, result}, _} = AOC.time(fn -> apply(mod, part, [input]) end, silent: true)

			{results, parts} =
				if result == nil do
					AOC.log_err("#{part} returned nil, skipping.")
					{results, parts}
				else
					{[{part, micros} | results], [{part, times - 1} | parts]}
				end

			bench(mod, input, results, parts)
		else
			bench(mod, input, results, parts)
		end
	end

	def extract_benchmarks!() do
		with {:ok, content} <- File.read("README.md"),
				 %{"benchs" => benchs} <- Regex.named_captures(benchmark_table_regex(), content),
				 benchs <- String.trim(benchs) do
			parse_markdown_table(benchs)
		else
			{:error, reason} -> AOC.log_err!(reason)
			nil -> AOC.log_err!("Couldn't find benchmark table in README.md")
		end
	end

	def set_benchmark_table!(rows) when is_list(rows) do
		benchs = [
			benchmark_table_mark(),
			"## Benchmarks",
			"",
			"| Year | Day | Part 1 | Part 2 |",
			"| :---: | :---: | :---: | :---: |"
		]

		entries = for row <- rows, do: to_string(row)

		benchmarks =
			[Enum.join(benchs, "\n"), Enum.join(entries, "\n"), benchmark_table_mark()]
			|> Enum.join("\n")

		case File.read("README.md") do
			{:ok, content} ->
				File.write!("README.md", Regex.replace(benchmark_table_regex(), content, benchmarks))
				IO.puts("\e[32mSaved benchmarks to README.md\e[0m")

			{:error, reason} ->
				AOC.log_err!(reason)
		end
	end

	def parse_markdown_table(table) do
		rows = String.split(table, "\n")

		if length(rows) > 2 do
			[_, _ | rows] =
				Enum.map(rows, fn row ->
					cols = for col <- String.split(row, "|"), do: String.trim(col)
					for col <- cols, col != "", do: col
				end)

			for row <- rows do
				AOC.BenchTiming.from(row)
			end
		else
			[]
		end
	end

	def benchmark_table_regex do
		~r/<!--- benchmarking table --->\s##.*\s+(?<benchs>[\s\S]*?)<!--- benchmarking table --->/
	end

	def benchmark_table_mark, do: "<!--- benchmarking table --->"

	def arg_config do
		%{
			"year" => %AOC.ArgConfig{
				default: "all",
				validation_fn: fn year ->
					if year != "all", do: AOC.Year.validate(year), else: :ok
				end,
				format_fn: &AOC.Year.new!(&1)
			},
			"day" => %AOC.ArgConfig{
				default: "all",
				validation_fn: fn day ->
					if day != "all", do: AOC.Day.validate(day), else: :ok
				end,
				format_fn: &AOC.Day.new!(&1)
			},
			"save" => %AOC.ArgConfig{
				default: "missing",
				validation_fn: fn save ->
					if save in ["none", "all", "missing"] do
						:ok
					else
						{:error, "Save option has to be one of those values: none, all or missing"}
					end
				end
			},
			"times" => %AOC.ArgConfig{
				default: times_default(),
				validation_fn: fn times ->
					cond do
						String.match?(times, times_regex(:single_num)) -> :ok
						String.match?(times, times_regex(:one_key)) -> :ok
						String.match?(times, times_regex(:two_keys)) -> :ok
						true -> {:error, "Does not match patterns."}
					end
				end,
				format_fn: fn times ->
					parse_single_num(times) ||
						parse_one_key(times) ||
						parse_two_keys(times) ||
						AOC.log_err!("Failed to format argument.")
				end
			}
		}
	end

	def times_regex(:single_num), do: ~r/^(?<v>\d+)$/
	def times_regex(:one_key), do: ~r/^(?<k>[a-z_]+):(?<v>\d+)$/

	def times_regex(:two_keys),
		do: ~r/^(?<ka>[a-z_]+):(?<va>\d+),(?<kb>[a-z_]+):(?<vb>\d+)$/

	defp parse_single_num(times) do
		case Regex.named_captures(times_regex(:single_num), times) do
			%{"v" => value} ->
				{int, _} = Integer.parse(value)
				[part_one: int, part_two: int]

			_ ->
				nil
		end
	end

	defp parse_one_key(times) do
		case Regex.named_captures(times_regex(:one_key), times) do
			%{"k" => key, "v" => value} ->
				{int, _} = Integer.parse(value)

				case what_part(key) do
					:one -> [part_one: int, part_two: times_default(:part_two)]
					:two -> [part_one: times_default(:part_one), part_two: int]
					{:error, :unknown} -> AOC.log_err!("Unkonw key: #{key}")
				end

			_ ->
				nil
		end
	end

	defp parse_two_keys(times) do
		case Regex.named_captures(times_regex(:two_keys), times) do
			%{"ka" => key_a, "va" => value_a, "kb" => key_b, "vb" => value_b} ->
				{int_a, _} = Integer.parse(value_a)
				{int_b, _} = Integer.parse(value_b)

				part_a = what_part(key_a)
				part_b = what_part(key_b)

				int_one =
					cond do
						part_a == :one -> int_a
						part_b == :one -> int_b
						true -> times_default(:part_one)
					end

				int_two =
					cond do
						part_a == :two -> int_a
						part_b == :two -> int_b
						true -> times_default(:part_two)
					end

				[part_one: int_one, part_two: int_two]

			_ ->
				nil
		end
	end

	defp what_part(key) do
		case key do
			k when k in ["one", "part_one", "o"] -> :one
			k when k in ["two", "part_two", "t"] -> :two
			_ -> {:error, :unknown}
		end
	end

	def times_default,
		do: [part_one: times_default(:part_one), part_two: times_default(:part_two)]

	def times_default(:part_one), do: 5
	def times_default(:part_two), do: 5
end
