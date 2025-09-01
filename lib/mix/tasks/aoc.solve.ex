defmodule Mix.Tasks.Aoc.Solve do
  @moduledoc """
  Solve advent of code solutions.

  ## Arguments

  ### Required

  - `year`: the year...
  - `day`: the day...

  ### Optional

  - `silent`: Whether IO, of the parts, should be suppressed, defaults to `true`.
    - `true`: Suppress IO.
    - `false`: Don't suppress IO.
  - `part`: What part to run, defaults to `part_one,part_two`.
    - `part_one` or `one` or `o`: for part one.
    - `part_two` or `two` or `t`: for part two.

  ## Examples

      $ mix aoc.solve --year=2025 --day=24
      Solving Advent of Code 2025, Day 24...

      Solve part one.
      Solve part two.
      ---------
      Part One (<time>): <result>
      Part Two (<time>): <result>

      $ mix aoc.solve 2025 1 one
      Solving Advent of Code 2025, Day 1, Part One...

      Solve part one.
      -------------
      Part One (<time>): <result>
  """

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    {%{"year" => year, "day" => day, "silent" => silent, "parts" => parts}, _} =
      AOC.Args.parse(args)
      |> AOC.Args.apply_config!(arg_config())

    input_file = AOC.Path.get(:puzzle, [year, day, :input])

    solve_part_one = Enum.any?(parts, fn part -> part == :part_one end)
    solve_part_two = Enum.any?(parts, fn part -> part == :part_two end)

    with true <- File.exists?(input_file),
         input <- File.read!(input_file),
         {:ok, mod} <- AOC.Mod.get(year, day) do
      cond do
        solve_part_one and solve_part_two ->
          IO.puts(
            "Solving \e[32mAdvent of Code \e[35m#{year.year}\e[0m, Day \e[35m#{day.day}\e[0m...\n"
          )

        solve_part_one ->
          IO.puts(
            "Solving \e[32mAdvent of Code \e[35m#{year.year}\e[0m, Day \e[35m#{day.day}\e[0m, Part One...\n"
          )

        solve_part_two ->
          IO.puts(
            "Solving \e[32mAdvent of Code \e[35m#{year.year}\e[0m, Day \e[35m#{day.day}\e[0m, Part Two...\n"
          )
      end

      {part_one, _} =
        if solve_part_one do
          IO.puts("\e[34mSolve part one.\e[0m")
          AOC.time(fn -> apply(mod, :part_one, [input]) end, silent: silent)
        else
          {nil, nil}
        end

      {part_two, _} =
        if solve_part_two do
          IO.puts("\e[34mSolve part two.\e[0m")
          AOC.time(fn -> apply(mod, :part_two, [input]) end, silent: silent)
        else
          {nil, nil}
        end

      IO.puts("-------------")

      if part_one != nil do
        display_result("One", part_one)
      end

      if part_two != nil do
        display_result("Two", part_two)
      end
    else
      false -> AOC.log_err!("Input file (#{input_file}) does not exist.")
      {:error, reason} -> AOC.log_err!(reason)
    end
  end

  def display_result(part, {micros, result}) when is_binary(part) do
    result = if result == nil, do: "\e[31m✖", else: "\e[33m#{result}"
    IO.puts("Part #{part} (\e[3;35m#{AOC.format_micros(micros)}\e[0m): #{result}\e[0m")
  end

  def arg_config do
    # TODO: add silent option
    %{
      "year" => %AOC.ArgConfig{
        mode: :required,
        validation_fn: &AOC.Year.validate(&1),
        format_fn: &AOC.Year.new!(&1)
      },
      "day" => %AOC.ArgConfig{
        mode: :required,
        validation_fn: &AOC.Day.validate(&1),
        format_fn: &AOC.Day.new!(&1)
      },
      "silent" => %AOC.ArgConfig{
        mode: {:default, true},
        validation_fn: fn silent ->
          if silent in ["true", "false"],
            do: :ok,
            else: {:error, "invalid options"}
        end,
        format_fn: fn silent ->
          silent == "true"
        end
      },
      "parts" => %AOC.ArgConfig{
        mode: {:default, [:part_one, :part_two]},
        validation_fn: fn parts ->
          valid =
            for part <- String.split(parts, ",") do
              valid_part_one(part) ||
                valid_part_two(part)
            end

          if Enum.all?(valid),
            do: :ok,
            else: {:error, "invalid value: #{parts}"}
        end,
        format_fn: fn parts ->
          for part <- String.split(parts, ",") do
            cond do
              valid_part_one(part) -> :part_one
              valid_part_two(part) -> :part_two
              true -> AOC.log_err!("invalid value: #{part}")
            end
          end
        end
      }
    }
  end

  defp valid_part_one(part), do: part in ~w/part_one one o/
  defp valid_part_two(part), do: part in ~w/part_two two t/
end
