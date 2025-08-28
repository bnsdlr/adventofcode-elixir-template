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

  @impl Mix.Task
  def run(args) do
    %{"year" => year, "day" => day} =
      AOC.Args.parse(args)
      |> AOC.Args.apply_config!(arg_config())

    template =
      AOC.Path.get(:template, [:elixir])
      |> File.read!()
      |> String.replace("%MODUELE%", AOC.Mod.str(year, day))

    elixir_file = AOC.Path.get(:solution, [year, day])

    if File.exists?(elixir_file) do
      AOC.log_warn("Elixir file already exists, skiping.")
    else
      File.mkdir_p!(AOC.Path.get(:solution, [year]))
      File.write!(elixir_file, template)
      IO.puts("Created elixir file: \e[1;34m#{elixir_file}\e[0m")
    end

    input_file = AOC.Path.get(:puzzle, [year, day, :input])

    if File.exists?(input_file) do
      AOC.log_warn("Input file already exists, skiping.")
    else
      File.mkdir_p!(AOC.Path.get(:puzzle, [year, day]))
      File.write!(input_file, "")
      IO.puts("Created input file: \e[1;34m#{input_file}\e[0m")
    end

    example_file = AOC.Path.get(:puzzle, [year, day, 1])

    if File.exists?(example_file) do
      AOC.log_warn("Example file already exists, skiping.")
    else
      File.write!(example_file, "")
      IO.puts("Created example file: \e[1;34m#{example_file}\e[0m")
    end

  end

  def arg_config do
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
