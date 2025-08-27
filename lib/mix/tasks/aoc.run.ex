defmodule Mix.Tasks.Aoc.Run do
  @moduledoc """
  Run advent of code solutions.

  ## Examples

    $ mix aoc.run --year=2025 --day=24
    ...
    Run part one.
    ...
    Run part two.
    ---------
    Part One (<time>): <result>
    Part Two (<time>): <result>
  """

  use Mix.Task

  require Logger

  @impl Mix.Task
  def run(args) do
    args = AOC.parse_args(args)

    case args do
      %{"year" => year, "day" => day} ->
        AOC.day_num_valid!(day)
        AOC.year_num_valid!(year)

        input_path = AOC.input_file_path(year, day)

        if File.exists?(input_path) do
          case AOC.get_mod(year, day) do
            {:ok, mod} ->
              input = File.read!(input_path)

              IO.puts("Run part one.")
              part_one = AOC.time(fn -> apply(mod, :part_one, [input]) end)
              IO.puts("Run part two.")
              part_two = AOC.time(fn -> apply(mod, :part_two, [input]) end)

              IO.puts("---------")
              AOC.display_result(:one, part_one)
              AOC.display_result(:two, part_two)

            {:error, reason} ->
              Logger.error(reason)
          end
        else
          Logger.error("Could not find input file for year #{year} day #{day}: #{input_path}")
        end

      _ ->
        Logger.error("missing arguments")
    end
  end
end
