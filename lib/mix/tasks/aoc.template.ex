defmodule Mix.Tasks.Aoc.Template do
  @moduledoc """
  Create template files for the advent of code day.

  ## Examples

    $ mix aoc.template --year=2025 --day=2
    ...
    Created elixir file: lib/bin/Y2025/D02.ex
    Created input file: data/Y2025/D02/input.txt
    Created example file: data/Y2025/D02/example-1.txt

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

        template =
          AOC.elixir_template_file_path()
          |> File.read!()
          |> String.replace("%YEAR%", AOC.year_str(year))
          |> String.replace("%DAY%", AOC.day_str(day))

        File.mkdir_p!(AOC.elixir_dir_path(year))
        elixir_file = AOC.elixir_file_path(year, day)
        File.write!(elixir_file, template)

        IO.puts("Created elixir file: \e[1;34m#{elixir_file}\e[0m")

        File.mkdir_p!(AOC.input_dir_path(year, day))
        input_file = AOC.input_file_path(year, day)
        File.write!(input_file, "")

        IO.puts("Created input file: \e[1;34m#{input_file}\e[0m")

        File.mkdir_p!(AOC.example_dir_path(year, day))
        example_file = AOC.example_file_path(year, day, 1)
        File.write!(example_file, "")

        IO.puts("Created example file: \e[1;34m#{example_file}\e[0m")

      _ ->
        Logger.error("Make sure to provide year and day: --year=<year> --day=<day>")
    end
  end
end
