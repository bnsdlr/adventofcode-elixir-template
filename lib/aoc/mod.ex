defmodule AOC.Mod do
  def str(year, day), do: "Bin.#{year}.#{day}"

  @doc """
  Get the module for the given `year` and `day` string, and make sure its loaded.
  """
  def get(year, day) do
    mod_path = AOC.Path.get(:solution, [year, day])

    if File.exists?(mod_path) do
      mod = String.to_existing_atom("Elixir.Bin.#{year}.#{day}")

      # Make sure the module is loaded
      _ = AOC.time(fn -> apply(mod, :tests, []) end)

      {:ok, mod}
    else
      {:error, "Could not find file for year #{year} day #{day}: #{mod_path}"}
    end
  end
end
