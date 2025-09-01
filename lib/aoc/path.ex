defmodule AOC.Path do
	@doc """
	Router for paths.

	## Examples

		iex> AOC.Path.get(:template, [:elixir])
		AOC.Path.Template.get(:elixir)

		iex> AOC.Path.get(:solution, [%AOC.Year{year: 2025}, %AOC.Day{day: 1}])
		AOC.Path.Solution.get(%AOC.Year{year: 2025}, %AOC.Day{day: 1})

		iex> AOC.Path.get(:puzzle, [%AOC.Year{year: 2025}, %AOC.Day{day: 1}, :input])
		AOC.Path.Puzzle.get(%AOC.Year{year: 2025}, %AOC.Day{day: 1}, :input)
	"""
	def get(atom, args \\ [])
	def get(:template, args), do: apply(AOC.Path.Template, :get, args)
	def get(:solution, args), do: apply(AOC.Path.Solution, :get, args)
	def get(:puzzle, args), do: apply(AOC.Path.Puzzle, :get, args)
end
