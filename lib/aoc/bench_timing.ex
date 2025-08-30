defmodule AOC.BenchTiming do
  @enforce_keys [:year, :day]
  defstruct [:year, :day, :part_one_timing, :part_two_timing]

  def from(list) when is_list(list) do
    [year, day, p1t, p2t] = list
    year = extract_year!(year)
    day = extract_day!(day)
    p1t = extract_timing!(p1t)
    p2t = extract_timing!(p2t)

    %__MODULE__{
      year: year,
      day: day,
      part_one_timing: p1t,
      part_two_timing: p2t
    }
  end

  def from(year, day, list) when is_list(list) do
    p1t = Keyword.get(list, :part_one, nil)
    p2t = Keyword.get(list, :part_two, nil)

    %__MODULE__{
      year: year,
      day: day,
      part_one_timing: p1t,
      part_two_timing: p2t
    }
  end

  defp extract_timing!(timing) when is_binary(timing) do
    if timing != "`-`" do
      case Regex.run(~r/^`([0-9]+.[0-9]+)([a-zµ]+)`$/, timing) do
        [_, timing, unit] ->
          with {timing, _} <- Float.parse(timing) do
            case unit do
              "µs" -> timing
              "ms" -> timing * 1000
              _ -> AOC.log_err!("Timing unit (#{unit}) unknown.")
            end
          else
            :error -> AOC.log_err!("Failed to parse timing (#{timing}) as a float.")
          end

        _ ->
          AOC.log_err!("Couldn't extract timing.")
      end
    else
      0.0
    end
  end

  defp extract_day!(day) when is_binary(day) do
    case Regex.run(~r/^\[Day\s([\d]+)\]\(.*\)$/, day) do
      [_, day] ->
        case AOC.Day.new(day) do
          {:ok, day_struct} -> day_struct
          {:error, reason} -> AOC.log_err!(reason)
        end

      _ ->
        AOC.log_err!("Couldn't extract day.")
    end
  end

  defp extract_year!(year) when is_binary(year) do
    case Regex.run(~r/^\[([\d]{4,4})\]\(.*\)$/, year) do
      [_, year] ->
        case AOC.Year.new(year) do
          {:ok, year_struct} -> year_struct
          {:error, reason} -> AOC.log_err!(reason)
        end

      _ ->
        AOC.log_err!("Couldn't extract year.")
    end
  end
end

defimpl String.Chars, for: AOC.BenchTiming do
  def to_string(timing) do
    %{year: year, day: day, part_one_timing: p1_timing, part_two_timing: p2_timing} =
      timing

    year_int = year.year
    day_int = day.day
    solution_path = AOC.Path.get(:solution, [year, day])

    p1_timing = if p1_timing == nil, do: "-", else: AOC.format_micros(p1_timing)
    p2_timing = if p2_timing == nil, do: "-", else: AOC.format_micros(p2_timing)

    "| [#{year_int}](https://adventofcode.com/#{year_int}) | [Day #{day_int}](./#{solution_path}) | `#{p1_timing}` | `#{p2_timing}` |"
  end
end
