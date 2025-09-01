defmodule AOC.Args do
  @doc """
   Parse CLI arguments.

  ## Examples

  	iex> AOC.Args.parse(["--year=2025", "--day=1"])
  	{%{"year" => "2025", "day" => "1"}, []}

  	iex> AOC.Args.parse(["-opt=true"])
  	{%{"opt" => "true"}, []}

    iex> AOC.Args.parse(["--opt", "2025"])
    {%{"opt" => "true"}, ["2025"]}
  """
  def parse(args) do
    key_reg = ~r/^--?(?<key>[a-z0-9-]+)$/
    key_val_reg = ~r/^--?(?<key>[a-z0-9-]+)=(?<value>.*)$/

    Enum.reduce(args, {%{}, []}, fn arg, {map, no_keys} ->
      cond do
        String.match?(arg, key_reg) ->
          %{"key" => key} = Regex.named_captures(key_reg, arg)
          {Map.put(map, key, "true"), no_keys}

        String.match?(arg, key_val_reg) ->
          %{"key" => key, "value" => value} =
            Regex.named_captures(
              ~r/^--?(?<key>[a-z0-9-]+)=(?<value>.*)/,
              arg
            )

          {Map.put(map, key, value), no_keys}

        true ->
          {map, [arg | no_keys]}
      end
    end)
  end

  @doc """
  Applies the given `config` to the `args`.

   - `args`: {%{"<key>" => "<value>"}, [<no_key_value>, ...]}
   - `config`: `AOC.ArgConfig`

  ## Examples

  	iex> AOC.Args.apply_config({%{}, []}, %{"year" => %AOC.ArgConfig{mode: {:default, "2025"}}})
  	{%{"year" => "2025"}, [], []}

  	iex> AOC.Args.apply_config({%{}, []}, %{"year" => %AOC.ArgConfig{mode: :required}})
  	{%{}, [required: ["year"]], []}

  	iex> AOC.Args.apply_config({%{"year" => "2025"}, []}, %{"year" => %AOC.ArgConfig{ 
  	...>	 validation_fn: fn year -> String.length(year) == 4 end
  	...> }})
  	{%{"year" => "2025"}, [], []}

  	iex> AOC.Args.apply_config({%{"year" => "0"}, []}, %{"year" => %AOC.ArgConfig{ 
  	...>	 validation_fn: fn year -> 
  	...>		 if String.length(year) == 4 do
  	...>				:ok
  	...>		 else
  	...>			 {:error, "string to short"}
  	...>		 end
  	...> end}})
  	{%{}, [invalid: [{"year", "string to short"}]], []}

    iex> AOC.Args.apply_config({%{}, ["2025"]}, %{"year" => %AOC.ArgConfig{
    ...>   mode: :required,
    ...>   validation_fn: &AOC.Year.validate(&1),
    ...> }})
    {%{"year" => "2025"}, [], []}
  """
  def apply_config({args, no_keys}, config) do
    Enum.reduce(config, {%{}, [], no_keys}, fn {arg, conf}, {nargs, errors, no_keys} ->
      if Map.has_key?(args, arg) do
        with true <- conf.validation_fn != nil,
             :ok <- conf.validation_fn.(args[arg]) do
          {Map.put(nargs, arg, conf.format_fn.(args[arg])), errors, no_keys}
        else
          {:error, reason} ->
            error = {arg, reason}

            {nargs, Keyword.update(errors, :invalid, [error], fn val -> [error | val] end),
             no_keys}

          _ ->
            {Map.put(nargs, arg, args[arg]), errors, no_keys}
        end
      else
        matching =
          Enum.filter(no_keys, fn val ->
            if conf.value_fn? != nil,
              do: conf.value_fn?.(val),
              else: conf.validation_fn && conf.validation_fn.(val) == :ok
          end)

        case conf.mode do
          :required ->
            case matching do
              [value | _] ->
                {Map.put(nargs, arg, conf.format_fn.(value)), errors, no_keys -- [value]}

              _ ->
                {nargs, Keyword.update(errors, :required, [arg], fn old -> [arg | old] end),
                 no_keys}
            end

          {:default, default_value} ->
            case matching do
              [value | _] ->
                {Map.put(nargs, arg, conf.format_fn.(value)), errors, no_keys -- [value]}

              _ ->
                {Map.put(nargs, arg, default_value), errors, no_keys}
            end

          :optional ->
            {nargs, errors, no_keys}
        end
      end
    end)
  end

  @doc """
  Same as `AOC.Args.apply_config/2` but may raise an error, 
  instead of returning it.
  """
  def apply_config!({args, no_keys}, config) do
    {args, errors, no_keys} = apply_config({args, no_keys}, config)

    has_invalids = Keyword.has_key?(errors, :invalid)

    if has_invalids do
      for {arg, reason} <- errors[:invalid] do
        AOC.log_err("Arg invalid (#{arg}): " <> reason)
      end
    end

    if Keyword.has_key?(errors, :required) and not Enum.empty?(errors[:required]) do
      AOC.log_err!("Missing arguments: #{Enum.join(errors[:required], ", ")}")
    end

    if not Enum.empty?(no_keys) do
      AOC.log_err!("Invalid option: #{Enum.join(no_keys, ", ")}")
    end

    if has_invalids, do: exit(:shutdown)

    {args, no_keys}
  end
end
