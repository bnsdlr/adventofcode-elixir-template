defmodule AOC do
  @moduledoc """
  Some utiliti functions.
  """

  def time(task) do
    started = Time.utc_now()
    result = task.()
    micros = Time.diff(Time.utc_now(), started, :microsecond)
    {micros, result}
  end

  @doc """
  Returns formated `day` string.

  ## Examples 
    
    iex> AOC.day_str("1")
    "D01"

    iex> AOC.day_str("25")
    "D25"
  """
  def day_str(day), do: "D" <> String.pad_leading(day, 2, "0")

  @doc """
  Returns formated `year` string.

  ## Examples
    
    iex> AOC.year_str("2025")
    "Y2025"

    iex> AOC.year_str("25")
    "Y25"
  """
  def year_str(year), do: "Y" <> year

  def day_reg(), do: ~r/D([0-9]{2,2})/
  def day_file_reg(), do: ~r/D([0-9]{2,2}).ex/
  def year_reg(), do: ~r/Y([0-9]{4,4})/

  @doc """
  Checks if the given `day` string is valid or not.

  ## Examples

    iex> AOC.day_num_valid?("1")
    true

    iex> AOC.day_num_valid?("01")
    true

    iey> AOC.day_num_valid?("25")
    true

  Invalid:

    iex> AOC.day_num_valid?("26")
    false
  """
  def day_num_valid?(day) do
    if not String.match?(day, ~r/[0-9]{1,2}/) do
      false
    else
      case Integer.parse(day) do
        {int, _} when int < 1 or int > 25 -> false
        :error -> false
        _ -> true
      end
    end
  end

  @doc "Same as `AOC.day_num_valid?/1` but raises an error."
  def day_num_valid!(day) do
    if not day_num_valid?(day) do
      raise "Invalid day number: day #{day} has to be in range from 01 to 25."
    end
  end

  @doc """
  Checks whether `year` string is valid.

  ## Examples
    
    iex> AOC.year_num_valid?("2025")
    true

    iex> AOC.year_num_valid?("25")
    false
  """
  def year_num_valid?(year), do: String.match?(year, ~r/[0-9]{4,4}/)

  @doc "Same as `AOC.year_num_valid?/1` bur raises an error."
  def year_num_valid!(year) do
    if not year_num_valid?(year) do
      raise "Invalid year number: year #{year} has to be 4 digits long, e.g. 2025."
    end
  end

  def elixir_year_dir_path(), do: "lib/bin"
  def elixir_dir_path(year), do: elixir_year_dir_path() <> "/#{year_str(year)}"
  def elixir_file_path(year, day), do: elixir_dir_path(year) <> "/#{day_str(day)}.ex"

  def input_dir_path(year, day), do: "data/#{year_str(year)}/#{day_str(day)}"
  def input_file_path(year, day), do: input_dir_path(year, day) <> "/input.txt"

  def example_dir_path(year, day), do: "data/#{year_str(year)}/#{day_str(day)}"
  def example_file_path(year, day, example),
    do: example_dir_path(year, day) <> "/example-#{example}.txt"

  def elixir_template_file_path, do: "data/templates/elixir.ex.txt"

  def display_result(:one, result), do: display_result("One", result)
  def display_result(:two, result), do: display_result("Two", result)

  def display_result(part, {μs, result}) when is_binary(part) do
    result = if result == nil, do: "\e[31m✖", else: "\e[33m#{result}"
    IO.puts("Part #{part} (\e[3;35m#{μs / 1000}ms\e[0m): #{result}\e[0m")
  end

  def run_for(year, day, fun) do
    f = fn v, path, reg, default ->
      if v == "all" do
        for dir <- File.ls!(path),
            String.match?(dir, reg),
            do: dir
      else
        default
      end
    end

    years = f.(year, elixir_year_dir_path(), year_reg(), [year])

    for year <- years do
      days = f.(day, elixir_year_dir_path() <> "/" <> year, day_file_reg(), [day])

      for day <- days do
        year_num = Enum.at(Regex.run(year_reg(), year, capture: :all), 1)
        day_num = Enum.at(Regex.run(day_file_reg(), day, capture: :all), 1)
        fun.({year_num, day_num}, {year, day})
      end
    end
  end

  @doc """
  Get the module for the given `year` and `day` string.
  """
  def get_mod(year, day) do
    mod_path = AOC.elixir_file_path(year, day)

    if File.exists?(mod_path) do
      mod = String.to_existing_atom("Elixir.Bin.#{year_str(year)}.#{day_str(day)}")

      Code.ensure_loaded(mod)
      # Make sure the module is loaded
      _ = AOC.time(fn -> apply(mod, :part_one_test, []) end)

      {:ok, mod}
    else
      {:error, "Could not find file for year #{year} day #{day}: #{mod_path}"}
    end
  end

  @doc """
  Parse the given argument list.

  ## Examples
    
    iex> AOC.parse_args(["--year=2025", "--day=2"])
    %{"year" => "2025", "day" => "2"}

    iex> AOC.parse_args(["--all"])
    %{"all" => true}

  """
  def parse_args(args) do
    Enum.reduce(args, %{}, fn arg, acc ->
      {key, value} = parse_arg(arg)
      Map.put(acc, key, value)
    end)
  end

  defp parse_arg(arg) do
    arg = String.replace_leading(arg, "-", "")

    if String.match?(arg, ~r/^[a-z0-9-]+=.*$/) do
      [key, value] = String.split(arg, "=", parts: 2)
      {key, value}
    else
      {arg, true}
    end
  end

  @doc """
  Set default values for args.

  ## Example

    iex> AOC.set_defaults(%{}, %{"year" => "all"})
    %{"year" => "all"}

    iex> AOC.set_defaults(%{"year" => "2025"}, %{"year" => "all"})
    %{"year" => "2025"}

  """
  def set_defaults(args, defaults \\ %{}) do
    Enum.reduce(defaults, args, fn {key, value}, acc ->
      if not Map.has_key?(acc, key) do
        Map.put(acc, key, value)
      else
        acc
      end
    end)
  end
end
