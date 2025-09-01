defmodule AOC.ArgConfig do
	@moduledoc """
	Configuration for command-line argument parsing and validation.

	This struct defines how individual arguments should be processed, validated,
	and formatted during argument parsing operations.

	## Fields

	- `default` - A default value to use when the argument is not provided
	- `validation_fn` - A function that validates the argument value. Should accept
		the value as an argument and return `:ok` if valid or `{:error, reason}` if invalid.
		Note: This function is not called on the default value
	- `required` - Boolean indicating whether this argument is required (`true`) or optional (`false`)
	- `format_fn` - A function to format or transform the argument value, returns formated value.

	## Example

		%{
			"year" => %AOC.ArgConfig{
				default: "all",
				required: false,
				validation_fn: fn year -> 
					if String.match?(year, ~r/^([0-9]{4,4}|[0-9]{2,2})/) do
						:ok
					else
						{:error, "some error message"}
					end
				end
			}
		}
	"""
	defstruct [:default, :required, :validation_fn, :format_fn]
end
