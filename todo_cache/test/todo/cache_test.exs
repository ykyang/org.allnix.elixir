defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    todc = Todo.Cache

    {:ok, cache} = todc.start()
    pid_bob = todc.server_process(cache, "bob")
    assert pid_bob != todc.server_process(cache, "alice")
    assert pid_bob == todc.server_process(cache, "bob")
  end

  test "todo operations" do
    tcah = Todo.Cache
    tsrv = Todo.Server

    {:ok, cache} = tcah.start()

    alice = tcah.server_process(cache, "alice")
    tsrv.add_entry(alice, %{date: ~D[2023-12-19], title: "Dentist"})

    entries = tsrv.entries(alice, ~D[2023-12-19])
    ## Use pattern match
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries
  end
end
