defmodule AOC.Year do
	@enforce_keys [:year]
	defstruct [:year]

	def is_year(%AOC.Year{year: _}), do: true

	def new(year) when is_binary(year) do
		with :ok <- validate(year),
				 {year_int, _} <- Integer.parse(year) do
			{:ok, %__MODULE__{year: year_int}}
		else
			{:error, reason} -> {:error, reason}
			:error -> validate_error(:parse)
		end
	end

	def new!(year) do
		case new(year) do
			{:ok, year_struct} -> year_struct
			{:error, reason} -> AOC.log_err!(reason)
		end
	end

	@doc """
	Create new `AOC.Year` struct from string: "Y<year>"

	## Examples

		iex> AOC.Year.from("Y2025", :with_prefix)
		{:ok, %AOC.Year{year: 2025}}

		iex> AOC.Year.from("2025", :with_prefix)
		AOC.Year.validate_error(:regex)
	"""
	def from(year, :with_prefix) when is_binary(year) do
		with :ok <- validate(year, :with_prefix),
				 %{"year" => year} <- Regex.named_captures(validation_regex(:with_prefix), year),
				 {year_int, _} <- Integer.parse(year) do
			{:ok, %__MODULE__{year: year_int}}
		else
			{:error, reason} -> {:error, reason}
			:error -> validate_error(:parse)
			_ -> {:error, "Unexpected"}
		end
	end

	@doc "Same as `AOC.Year.from/2` but raises on error."
	def from!(year, :with_prefix) when is_binary(year) do
		case from(year, :with_prefix) do
			{:ok, year_struct} -> year_struct
			{:error, reason} -> AOC.log_err!(reason)
		end
	end

	def validate_error(:not_in_range),
		do: {:error, "Year has to be from 2000 to 2099."}

	def validate_error(:parse),
		do: {:error, "Failed to parse year as an integer."}

	def validate_error(:regex),
		do: {:error, "Year has to be four digits, e.g. 2025 or 2015"}

	@doc """
	Checks if the `year` is valid.

	Is valid when: `year` is in 2000..2099.

	## Examples

		iex> AOC.Year.validate("2025")
		:ok

		iex> AOC.Year.validate("Y2025", :with_prefix)
		:ok

		iex> AOC.Year.validate(2025)
		:ok

		iex> AOC.Year.validate("1999")
		AOC.Year.validate_error(:not_in_range)

		iex> AOC.Year.validate("25")
		AOC.Year.validate_error(:regex)

		iex> AOC.Year.validate("Y2025")
		AOC.Year.validate_error(:regex)
	"""
	def validate(year)

	def validate(year) when is_struct(year) do
		validate(year.year)
	end

	def validate(year) when is_integer(year) do
		if year in 2000..2099, do: :ok, else: validate_error(:not_in_range)
	end

	def validate(year) when is_binary(year) do
		with true <- String.match?(year, validation_regex()),
				 {year_int, _} <- Integer.parse(year) do
			validate(year_int)
		else
			false -> validate_error(:regex)
			:error -> validate_error(:parse)
		end
	end

	def validate(year, :with_prefix) when is_binary(year) do
		regex = validation_regex(:with_prefix)

		with true <- String.match?(year, regex),
				 %{"year" => year} <- Regex.named_captures(regex, year),
				 {year_int, _} <- Integer.parse(year) do
			validate(year_int)
		else
			false -> validate_error(:regex)
			:error -> validate_error(:parse)
		end
	end

	def validation_regex(), do: ~r/^[0-9]{4,4}/
	def validation_regex(:with_prefix), do: ~r/^Y(?<year>[0-9]{4,4})/
end

defimpl String.Chars, for: AOC.Year do
	# It has to start with a Letter, so we can name a module.
	def to_string(year) when is_integer(year.year) do
		if year.year < 100 do
			"Y20" <> Kernel.to_string(year.year)
		else
			"Y" <> Kernel.to_string(year.year)
		end
	end
end
