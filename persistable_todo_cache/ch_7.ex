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
  ## 7.3.2 Using the database
  ## Part 1
  #  c(["ch_7.ex"]); Ch7.test_ch7_4()
  def test_ch7_4() do
    # Delete
    File.rm("./persist/bobs_list")

    tdch = Todo.Cache
    tsrv = Todo.Server

    {:ok, cache} = Todo.Cache.start()
    bob = tdch.server_process(cache, "bobs_list")
    tsrv.add_entry(bob, %{date: ~D[2023-12-19], title: "Dentist"})
    entries = tsrv.entries(bob, ~D[2023-12-19])
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries

    Process.sleep(1) # wait for IO
    assert File.exists?("persist/bobs_list") == true

    :ok
  end
  ## Part 2
  #  c(["ch_7.ex"]); Ch7.test_ch7_4(); Ch7.test_ch7_5()
  def test_ch7_5() do
    tcah = Todo.Cache
    tsrv = Todo.Server

    {:ok, cache} = tcah.start()
    bob = tcah.server_process(cache, "bobs_list")

    entries = tsrv.entries(bob, ~D[2023-12-19])
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries

    :ok
  end
  ## 7.3.3 Analyzing the system
  ## 7.3.4 Addressing the process bottleneck
  ## 7.3.5 Exercise: pooling and synchronizing
  #  c(["ch_7.ex"]); Ch7.test_ch7_6();
  ## Part 1
  def test_ch7_6() do
    # Delete
    File.rm("./persist/bobs_list")
    File.rm("./persist/amys_list")

    tcah = Todo.Cache
    tsrv = Todo.Server

    {:ok, pid_cache} = tcah.start()
    IO.inspect(pid_cache, label: "Cache")

    pid = tcah.server_process(pid_cache, "bobs_list")
    IO.inspect(pid, label: "Bob")

    out = tsrv.add_entry(pid, %{date: ~D[2023-12-19], title: "Dentist"})
    IO.inspect(out, label: "Bob add_entry")

    entries = tsrv.entries(pid, ~D[2023-12-19])
    IO.inspect(entries, label: "entries")
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries


    pid = tcah.server_process(pid_cache, "amys_list")
    IO.inspect(pid, label: "Amy")

    out = tsrv.add_entry(pid, %{date: ~D[2023-12-19], title: "Dentist"})
    IO.inspect(out, label: "Amy add_entry")

    entries = tsrv.entries(pid, ~D[2023-12-19])
    IO.inspect(entries, label: "entries")
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries

    :ok
  end

  ## Part 2
  #  c(["ch_7.ex"]); Ch7.test_ch7_6(); Ch7.test_ch7_7();
  def test_ch7_7() do
    tcah = Todo.Cache
    tsrv = Todo.Server

    {:ok, cache} = tcah.start()

    pid = tcah.server_process(cache, "bobs_list")
    entries = tsrv.entries(pid, ~D[2023-12-19])
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries

    pid = tcah.server_process(cache, "amys_list")
    entries = tsrv.entries(pid, ~D[2023-12-19])
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries

    :ok
  end
  ## 7.4 Reasoning with processes
end
