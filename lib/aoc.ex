defmodule AOC do
	@moduledoc """
	Some utiliti functions.
	"""

	@doc """
	Measures the time spend executing the `task`.
	"""
	def time(task, opts \\ [])

	def time(task, []) when is_function(task, 0) do
		started = Time.utc_now()
		result = task.()
		micros = Time.diff(Time.utc_now(), started, :microsecond)
		{micros, result}
	end

	def time(task, opts) when is_function(task, 0) do
		silent = Keyword.get(opts, :silent, false)

		if silent do
			{{micros, result}, io} =
				ExUnit.CaptureIO.with_io(fn ->
					time(task)
				end)

			{{micros, result}, io}
		else
			time(task)
		end
	end

	def format_micros(micros) do
		if micros > 1000 do
			ms = :erlang.float_to_binary(micros / 1000, [{:decimals, 3}, :compact])
			"#{ms}ms"
		else
			"#{micros}µs"
		end
	end

	# log
	def log_err(msg) do
		IO.puts(:stderr, "\e[31m" <> msg <> "\e[0m")
	end

	def log_err!(msg) do
		raise "\e[31m" <> msg <> "\e[0m"
	end

	def log_warn(msg) do
		IO.puts(:stderr, "\e[33m" <> msg <> "\e[0m")
	end

	def log_warn!(msg) do
		raise "\e[33m" <> msg <> "\e[0m"
	end
end
