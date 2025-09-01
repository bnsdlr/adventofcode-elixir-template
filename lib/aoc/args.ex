defmodule AOC.Args do
	@doc """
	Parse CLI arguments.

	## Examples

		iex> AOC.Args.parse(["--year=2025", "--day=1"])
		%{"year" => "2025", "day" => "1"}

		iex> AOC.Args.parse(["-opt=true"])
		%{"opt" => "true"}
	"""
	def parse(args) do
		key_val_reg = ~r/^--?(?<key>[a-z0-9-]+)=(?<value>.*)/

		Enum.reduce(args, %{}, fn arg, acc ->
			if not String.match?(arg, key_val_reg) do
				AOC.log_err!("Argument doesn't match key value pattern (--<key>=<value>).")
				acc
			else
				%{"key" => key, "value" => value} =
					Regex.named_captures(
						~r/^--?(?<key>[a-z0-9-]+)=(?<value>.*)/,
						arg
					)

				Map.put(acc, key, value)
			end
		end)
	end

	@doc """
	Applies the given `config` to the `args`.

	 - `args`: %{"<key>" => "<value>"}
	 - `config`: `AOC.ArgConfig`

	## Examples

		iex> AOC.Args.apply_config(%{}, %{"year" => %AOC.ArgConfig{default: "2025"}})
		{%{"year" => "2025"}, []}

		iex> AOC.Args.apply_config(%{}, %{"year" => %AOC.ArgConfig{required: true}})
		{%{}, [required: ["year"]]}

		iex> AOC.Args.apply_config(%{"year" => "2025"}, %{"year" => %AOC.ArgConfig{ 
		...>	 validation_fn: fn year -> String.length(year) == 4 end
		...> }})
		{%{"year" => "2025"}, []}

		iex> AOC.Args.apply_config(%{"year" => "0"}, %{"year" => %AOC.ArgConfig{ 
		...>	 validation_fn: fn year -> 
		...>		 if String.length(year) == 4 do
		...>				:ok
		...>		 else
		...>			 {:error, "string to short"}
		...>		 end
		...> end}})
		{%{}, [invalid: [{"year", "string to short"}]]}

	"""
	def apply_config(args, config) do
		Enum.reduce(config, {%{}, []}, fn {arg, conf}, {nargs, errors} ->
			cond do
				not Map.has_key?(args, arg) ->
					if conf.default != nil do
						{Map.put(nargs, arg, conf.default), errors}
					else
						{nargs, Keyword.update(errors, :required, [arg], fn val -> [arg | val] end)}
					end

				true ->
					with true <- conf.validation_fn != nil,
							 :ok <- conf.validation_fn.(args[arg]) do
						value =
							if conf.format_fn != nil do
								conf.format_fn.(args[arg])
							else
								args[arg]
							end

						{Map.put(nargs, arg, value), errors}
					else
						{:error, reason} ->
							error = {arg, reason}
							{nargs, Keyword.update(errors, :invalid, [error], fn val -> [error | val] end)}

						_ ->
							{Map.put(nargs, arg, args[arg]), errors}
					end
			end
		end)
	end

	@doc """
	Same as `AOC.Args.apply_config/2` but may raise an error, 
	instead of returning it.
	"""
	def apply_config!(args, config) do
		{args, errors} = apply_config(args, config)

		has_invalids = Keyword.has_key?(errors, :invalid)

		if has_invalids do
			for {arg, reason} <- errors[:invalid] do
				AOC.log_err("Arg invalid (#{arg}): " <> reason)
			end
		end

		if Keyword.has_key?(errors, :required) and not Enum.empty?(errors[:required]) do
			AOC.log_err!("Missing arguments: #{Enum.join(errors[:required], ", ")}")
		end

		if has_invalids, do: exit(:shutdown)

		args
	end
end
