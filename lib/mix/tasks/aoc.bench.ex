defmodule Mix.Tasks.Aoc.Bench do
  @moduledoc """
  Benchmark advent of code solutions.

  ## Options

  - `save`: Will only execute effected solutions, defaults to `none`.
    - `all`: Save all benchmarks to README.md.
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

    $ mix aoc.bench

  Bench all solutions and save `missing` benchmarks.

    $ mix aoc.bench --save=missing

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

    IO.inspect(save)
    IO.inspect(year)
    IO.inspect(day)
    IO.inspect(times)

    [part_one: part_one_times, part_two: part_two_times] = times

    solutions = AOC.Path.Solution.get!(year, day)

    for {year, day} <- Enum.sort_by(solutions, &"#{elem(&1, 0)}#{elem(&1, 1)}") do
      solution_file = AOC.Path.get(:solution, [year, day])
      IO.puts("\e[34mBenching \e[36m#{solution_file}\e[0m")
      IO.puts("\e[36m-----------------------------\e[0m")

      input_file = AOC.Path.get(:puzzle, [year, day, :input])

      if File.exists?(input_file) do
        input = File.read!(input_file)

        case AOC.Mod.get(year, day) do
          {:ok, mod} ->
            benches = bench(mod, input, part_one: part_one_times, part_two: part_two_times)

            benches =
              Enum.reduce(benches, [], fn {part, micros}, acc ->
                elem(
                  Keyword.get_and_update(acc, part, fn current ->
                    if current == nil,
                      do: {current, [micros]},
                      else: {current, [micros | current]}
                  end),
                  1
                )
              end)

            for {part, times} <- benches do
              length = length(times)
              avg = Enum.sum(times) / length
              avg = :erlang.float_to_binary(avg / 1000, [{:decimals, 3}, :compact])
              IO.puts("#{part}: #{avg}ms (#{length})")
            end

          {:error, reason} ->
            AOC.log_err(reason)
        end
      else
        AOC.log_err("Could not locate input file: \e[36m#{input_file}\e[0m")
      end

      IO.puts("")
    end
  end

  def bench(_mod, _input, results, []), do: results

  def bench(mod, input, results, parts) when is_list(parts) do
    [{part, times} | parts] = parts

    if times > 0 do
      IO.puts("Benching #{part}: #{times}\e[1A")
      {micros, result} = AOC.time(fn -> apply(mod, part, [input]) end, silent: true)

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

  def bench(mod, input, parts), do: bench(mod, input, [], parts)

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
        default: "none",
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
