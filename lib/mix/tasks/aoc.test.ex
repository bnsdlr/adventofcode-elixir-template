defmodule Mix.Tasks.Aoc.Test do
  @moduledoc """
  Test advent of code solutions.

  - `--year`: defaults to `all`
  - `--day`: defaults to `all`

  ## Examples

    $ mix aoc.test --year=2025 --day=24

    $ mix aoc.test --year=2025 --day=all

    $ mix aoc.test --year=all --day=all
  """

  use Mix.Task

  require Logger

  @impl Mix.Task
  def run(args) do
    %{"year" => year, "day" => day} =
      AOC.parse_args(args)
      |> AOC.set_defaults(%{"year" => "all", "day" => "all"})

    if year != "all", do: AOC.year_num_valid!(year)
    if day != "all", do: AOC.day_num_valid!(day)

    AOC.run_for(year, day, fn {year, day}, {year_dir, day_file} ->
      IO.puts("Testing (#{year}.#{day}) at lib/bin/#{year_dir}/#{day_file}")

      case AOC.get_mod(year, day) do
        {:ok, mod} ->
          IO.puts("\e[36mTesting Part One\e[0m")

          %{result: result, example: example} =
            apply(mod, :part_one_test, [])

          example_file = AOC.example_file_path(year, day, example)
          example_input = File.read!(example_file)

          {micros, res} = AOC.time(fn -> apply(mod, :part_one, [example_input]) end)

          if res == result do
            IO.puts("\e[32mPart One succeded in \e[3;35m#{micros / 1000}ms\e[0m")
          else
            IO.puts("\e[31mPart One failed, expected #{inspect(result)} got #{inspect(res)}\e[0m")
          end

        {:error, reason} ->
          Logger.error(reason)
      end
    end)
  end
end
