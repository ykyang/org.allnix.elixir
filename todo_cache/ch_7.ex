## Start iex
# iex -S mix
#
## Open in Erlang window
# iex --werl
#
## Fix font not displayed properly
# chcp 65001 # from https://groups.google.com/g/elixir-lang-talk/c/C6YrOKQ81PI
# iex
#
## Ignore warning, https://elixirforum.com/t/how-to-disable-redefining-warning/53342
# Code.put_compiler_option(:ignore_module_conflict, true)

defmodule Ch7 do
  import ExUnit.Assertions
  def collect_titles(entries) do
    titles = Enum.reduce(entries, MapSet.new(), fn entry, acc ->
      MapSet.put(acc, entry[:title])
    end)
    titles
  end

  ## 7.1 Working with the mix project
  #  c(["ch_7.ex"]); Ch7.test_ch7_1()
  def test_ch7_1() do
    tsr = Todo.Server
    {:ok, todo_server} = tsr.start()

    tsr.add_entry(todo_server, %{date: ~D[2023-12-19], title: "Dentist"})
    # Test
    entries = tsr.entries(todo_server, ~D[2023-12-19])
    assert collect_titles(entries) == MapSet.new(["Dentist"])

    tsr.add_entry(todo_server, %{date: ~D[2023-12-20], title: "Shopping"})
    tsr.add_entry(todo_server, %{date: ~D[2023-12-19], title: "Movie"})

    # Test
    entries = tsr.entries(todo_server, ~D[2023-12-19])
    assert collect_titles(entries) == MapSet.new(["Dentist", "Movie"])
    entries = tsr.entries(todo_server, ~D[2023-12-20])
    assert collect_titles(entries) == MapSet.new(["Shopping"])

    GenServer.stop(todo_server)
    tsr.stop(todo_server)
  end
  ## 7.2 Managing multiple to-do list
  ## 7.2.1 Implementing a cache
  # See todo_cache/
  #  c(["ch_7.ex"]); Ch7.test_ch7_2()
  def test_ch7_2() do
    tod = Todo.Cache
    srv = Todo.Server

    {:ok, cache} = tod.start()
    bob = tod.server_process(cache, "Bob's list")
    assert bob == tod.server_process(cache, "Bob's list")
    srv.add_entry(bob, %{date: ~D[2023-12-19], title: "Dentist"})
    assert srv.entries(bob, ~D[2023-12-19]) == [%{date: ~D[2023-12-19], id: 1, title: "Dentist"}]

    alice = tod.server_process(cache, "Alice's list")
    assert srv.entries(alice, ~D[2023-12-19]) == []

    :ok
  end
  ## Number of processes
  #  c(["ch_7.ex"]); Ch7.test_ch7_3()
  def test_ch7_3() do
    {:ok, cache} = Todo.Cache.start()
    no_proc = length(Process.list())
    Enum.each(1..100_000, fn ind ->
      Todo.Cache.server_process(cache, "todo list #{ind}")
    end
    )
    assert no_proc + 100_000 == length(Process.list())

    :ok
  end
  ## 7.2.2 Writing tests
  # see test/todo/cache_text.exs
  ## 7.3 Persisting data
  # see persistable_todo_cache
end
