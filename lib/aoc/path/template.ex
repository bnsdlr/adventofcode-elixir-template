defmodule AOC.Path.Template do
	def get(), do: "templates"
	def get(:elixir), do: get() <> "/elixir.ex.txt"
end
