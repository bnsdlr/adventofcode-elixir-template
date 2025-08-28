defmodule AOC.Path.Solution do
  def get(), do: "lib/bin"
  def get(year), do: get() <> "/#{year}"
  def get(year, day), do: get(year) <> "/#{day}.ex"

  def get!(year, day) do
    years =
      if year == "all" do
        get_matching!(
          get(),
          AOC.Year.validation_regex(:with_prefix),
          &AOC.Year.from!(&1, :with_prefix)
        )
      else
        [year]
      end

    for year <- years do
      if day == "all" do
        for day <-
              get_matching!(
                get(year),
                AOC.Day.validation_regex(:with_prefix_and_extension),
                &AOC.Day.from!(&1, :with_prefix_and_extension)
              ),
            do: {year, day}
      else
        [{year, day}]
      end
    end
    |> Enum.concat()
  end

  defp get_matching!(path, regex) do
    for item <- File.ls!(path) do
      if String.match?(item, regex), do: item
    end
  end

  defp get_matching!(path, regex, fun) do
    for item <- get_matching!(path, regex), do: fun.(item)
  end
end
