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

  ## Examples

  Bench all solutions but save none.

    $ mix aoc.bench

  Bench all solutions and save `missing` benchmarks.

    $ mix aoc.bench --save=missing

  Bench all solutions in specified `year` and save `all` benchmarks.

    $ mix aoc.bench --year=2025 --save=all
  """

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    %{"save" => save, "year" => year, "day" => day} =
      AOC.Args.parse(args)
      |> AOC.Args.apply_config!(arg_config())

    IO.inspect(save)
    IO.inspect(year)
    IO.inspect(day)
  end

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
      }
    }
  end
end
