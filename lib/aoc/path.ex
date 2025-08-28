defmodule AOC.Path do
  def get(atom, args \\ [])
  def get(:template, args), do: apply(AOC.Path.Template, :get, args)
  def get(:solution, args), do: apply(AOC.Path.Solution, :get, args)
  def get(:puzzle, args), do: apply(AOC.Path.Puzzle, :get, args)
end
