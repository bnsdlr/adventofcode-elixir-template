defmodule AOC.ArgConfig do
  @moduledoc """
  Configuration for command-line argument parsing and validation.

  This struct defines how individual arguments should be processed, validated,
  and formatted during argument parsing operations.

  ## Fields

  - `mode`: One of the following, defaults to `:optional`.
    - `:required`: make value required.
    - `:optional`: make value optional.
    - `{:default, <value>}`: set a default value.
  - `validation_fn`: A function that validates the argument value. Should accept
  	the value as an argument and return `:ok` if valid or `{:error, reason}` if invalid.
  	Note: This function is not called on the default value
  - `format_fn`: A function to format or transform the argument value, returns formated value.
  - `value_fn?`: A function that is run on all `no key` values (values passed without a key), 
  	the first match will be choosen, defaults to calling `validation_fn` and matching it to `:ok`.
    Return `true` on success and `false` on fail.

  ## Example

  	%{
  		"year" => %AOC.ArgConfig{
  			mode: {:default, "all"},
  			validation_fn: fn year -> 
  				if String.match?(year, ~r/^(all|[0-9]{4,4}|[0-9]{2,2})/) do
  					:ok
  				else
  					{:error, "some error message"}
  				end
  			end
  		}
  	}
  """
  defstruct [
    :validation_fn,
    :value_fn?,
    format_fn: &__MODULE__.return_self/1,
    mode: :optional
  ]

  def return_self(s), do: s
end
