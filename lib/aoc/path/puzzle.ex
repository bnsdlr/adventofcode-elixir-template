defmodule AOC.Path.Puzzle do
  def get(), do: "puzzles"
  def get(year), do: get() <> "/#{year}"
  def get(year, day), do: get(year) <> "/#{day}"
  def get(year, day, :input), do: get(year, day) <> "/input.txt"
  def get(year, day, :keep), do: get(year, day) <> "/.keep"
  def get(year, day, example), do: get(year, day) <> "/example-#{example}.txt"
end
