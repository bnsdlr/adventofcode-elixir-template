defmodule Mix.Tasks.Aoc.Test do
  @moduledoc """
  Test advent of code solutions.

  ## Arguments 

  ### Optional

  - `--year`: defaults to `all`
  - `--day`: defaults to `all`
  - `--silent`: defaults to `success`
  	- `success`: don't show IO on success, only on error.
  	- `always`: never show IO.

  ## Examples

  Test solution day 24 in year 2025.

      $ mix aoc.test 2025 1
      Testing lib/bin/Y2025/D01.ex
      ----------------------------
      Testing part_one
      Part One succeded in 0.009ms
      Testing part_two
      Part One succeded in 0.001ms

  Test all exisiting solutions of the year 2025.

      $ mix aoc.test 2025
      Testing lib/bin/Y2025/D01.ex
      ----------------------------
      Testing part_one
      Part One succeded in 0.023ms
      Testing part_two
      Part One succeded in 0.001ms
    
      Testing lib/bin/Y2025/D02.ex
      ----------------------------
      Testing part_one
      Part One succeded in 0.007ms
      Testing part_two
      Part One succeded in 0.002ms

  Test all solutions.

      $ mix aoc.test
      Testing lib/bin/Y2024/D01.ex
      ----------------------------
      Testing part_one
      Part One succeded in 0.023ms
      Testing part_two
      Part One succeded in 0.001ms
    
      Testing lib/bin/Y2025/D01.ex
      ----------------------------
      Testing part_one
      Part One succeded in 0.007ms
      Testing part_two
      Part One succeded in 0.002ms
  """

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {%{"year" => year, "day" => day, "silent" => silent}, _} =
      AOC.Args.parse(args)
      |> AOC.Args.apply_config!(arg_config())

    solutions = AOC.Path.Solution.get!(year, day)

    for {year, day} <- Enum.sort_by(solutions, &"#{elem(&1, 0)}#{elem(&1, 1)}") do
      IO.puts("\e[34mTesting \e[36mlib/bin/#{year}/#{day}.ex\e[0m")
      IO.puts("\e[36m----------------------------\e[0m")

      case AOC.Mod.get(year, day) do
        {:ok, mod} ->
          tests = apply(mod, :tests, [])

          for [part: part, result: result, example: example] <- tests do
            IO.puts("Testing \e[34m#{part}\e[0m")

            example_file = AOC.Path.get(:puzzle, [year, day, example])
            example_input = File.read!(example_file)

            {{micros, res}, io} =
              AOC.time(fn -> apply(mod, part, [example_input]) end, silent: true)

            if res == result do
              IO.puts("\e[32mPart One succeded in \e[3;35m#{micros / 1000}ms\e[0m")
            else
              if silent == "success" do
                IO.puts("Captured output:\n#{io}")
              end

              AOC.log_err("Part One failed, expected #{inspect(result)} got #{inspect(res)}")
            end
          end

        {:error, reason} ->
          AOC.log_err(reason)
      end

      IO.puts("")
    end
  end

  def arg_config do
    %{
      "year" => %AOC.ArgConfig{
        mode: {:default, "all"},
        validation_fn: fn year ->
          if year != "all", do: AOC.Year.validate(year), else: :ok
        end,
        format_fn: &AOC.Year.new!(&1),
        value_fn?: fn year -> AOC.Year.validate(year) == :ok end
      },
      "day" => %AOC.ArgConfig{
        mode: {:default, "all"},
        validation_fn: fn day ->
          if day != "all", do: AOC.Day.validate(day), else: :ok
        end,
        format_fn: &AOC.Day.new!(&1),
        value_fn?: fn day -> AOC.Day.validate(day) == :ok end
      },
      "silent" => %AOC.ArgConfig{
        mode: {:default, "success"},
        validation_fn: fn silent ->
          if silent in ["success", "always"],
            do: :ok,
            else: {:error, "silent options has to be one of: success, always"}
        end
      }
    }
  end
end
