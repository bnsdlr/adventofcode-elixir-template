defmodule AOC.Silence do
  def run(fun) when is_function(fun, 0) do
    {:ok, null_io} = StringIO.open("")
    old_leader = Process.group_leader()

    try do
      Process.group_leader(self(), null_io)
      fun.()
    after
      Process.group_leader(self(), old_leader)
    end
  end
end
