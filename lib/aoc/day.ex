defmodule AOC.Day do
  @enforce_keys [:day]
  defstruct [:day]

  def new(day) do
    with :ok <- validate(day),
         {day_int, _} <- Integer.parse(day) do
      {:ok, %__MODULE__{day: day_int}}
    else
      {:error, reason} -> {:error, reason}
      :error -> {:error, "Failed to parse day as an integer."}
    end
  end

  def new!(day) do
    case new(day) do
      {:ok, day_struct} -> day_struct
      {:error, reason} -> AOC.log_err!(reason)
    end
  end

  @doc """
  Create new `AOC.Day` struct from string: "D<day>"

  ## Examples

    iex> AOC.Day.from("01")
    {:ok, %AOC.Day{day: 1}}

    iex> AOC.Day.from("5")
    {:ok, %AOC.Day{day: 5}}

    iex> AOC.Day.from("D25", :with_prefix)
    {:ok, %AOC.Day{day: 25}}

    iex> AOC.Day.from("D25.ex", :with_prefix_and_extension)
    {:ok, %AOC.Day{day: 25}}

    iex> AOC.Day.from("25", :with_prefix)
    AOC.Day.validate_error(:regex, :with_prefix)

    iex> AOC.Day.from("25", :with_prefix_and_extension)
    AOC.Day.validate_error(:regex, :with_prefix_and_extension)
  """
  def from(day) when is_binary(day) do
    with :ok <- validate(day),
         %{"day" => day} <- Regex.named_captures(validation_regex(), day),
         {day_int, _} <- Integer.parse(day) do
      {:ok, %__MODULE__{day: day_int}}
    else
      {:error, reason} -> {:error, reason}
      :error -> validate_error(:parse)
      _ -> {:error, "Unexpected"}
    end
  end

  def from(day, :with_prefix) when is_binary(day) do
    with :ok <- validate(day, :with_prefix),
         day <- String.slice(day, 1..2) do
      from(day)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def from(day, :with_prefix_and_extension) when is_binary(day) do
    with :ok <- validate(day, :with_prefix_and_extension),
         day <- String.slice(day, 1..2) do
      from(day)
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc "Same as `AOC.Day.from/2` but raises on error."
  def from!(day) when is_binary(day) do
    case from(day) do
      {:ok, day_struct} -> day_struct
      {:error, reason} -> AOC.log_err!(reason)
    end
  end

  def from!(day, :with_prefix) when is_binary(day) do
    case from(day, :with_prefix) do
      {:ok, day_struct} -> day_struct
      {:error, reason} -> AOC.log_err!(reason)
    end
  end

  def from!(day, :with_prefix_and_extension) when is_binary(day) do
    case from(day, :with_prefix_and_extension) do
      {:ok, day_struct} -> day_struct
      {:error, reason} -> AOC.log_err!(reason)
    end
  end

  def validate_error(:parse),
    do: {:error, "Failed to parse day as an integer."}

  def validate_error(:not_in_range),
    do: {:error, "Day has to be between 1 to 25"}

  def validate_error(:regex),
    do: {:error, "Day to be one or two digits, e.g. 1 or 25."}

  def validate_error(:regex, :with_prefix),
    do:
      {:error, "Day to be one or two digits, e.g. 1 or 25, and start with a D, e.g. D24 or D01."}

  def validate_error(:regex, :with_prefix_and_extension),
    do: {:error, "Day to start with a D and end with .ex like D24.ex or D01.ex."}

  def validate(day) when is_struct(day) do
    validate(day.day)
  end

  def validate(day) when is_integer(day) do
    if day in 1..25 do
      :ok
    else
      validate_error(:not_in_range)
    end
  end

  def validate(day) when is_binary(day) do
    with true <- String.match?(day, validation_regex()),
         {day_int, _} = Integer.parse(day) do
      validate(day_int)
    else
      false -> validate_error(:not_in_range)
      :error -> validate_error(:parse)
    end
  end

  def validate(day, :with_prefix) when is_binary(day) do
    if String.match?(day, validation_regex(:with_prefix)),
      do: :ok,
      else: validate_error(:regex, :with_prefix)
  end

  def validate(day, :with_prefix_and_extension) when is_binary(day) do
    if String.match?(day, validation_regex(:with_prefix_and_extension)),
      do: :ok,
      else: validate_error(:regex, :with_prefix_and_extension)
  end

  def validation_regex(), do: ~r/^(?<day>[0-9]|[0-9]{2,2})$/
  def validation_regex(:with_prefix), do: ~r/^D(?<day>[0-9]{2,2})$/
  def validation_regex(:with_prefix_and_extension), do: ~r/^D(?<day>[0-9]{2,2}).ex$/
end

defimpl String.Chars, for: AOC.Day do
  # It has to start with a Letter, so we can name a module.
  def to_string(day) when is_integer(day.day) do
    "D" <> String.pad_leading(Kernel.to_string(day.day), 2, "0")
  end
end
