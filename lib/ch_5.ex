# iex --werl

# chcp 65001 # from https://groups.google.com/g/elixir-lang-talk/c/C6YrOKQ81PI
# iex
#
# c(["lib/todo_list.ex", "lib/ch_4.ex"])
# Ch4.test_ch4_1()
#
# Ignore warning, https://elixirforum.com/t/how-to-disable-redefining-warning/53342
# Code.put_compiler_option(:ignore_module_conflict, true)

defmodule Ch5 do
  alias Ch5.DatabaseServer
  alias Ch5.Calculator
  import ExUnit.Assertions
  ## 5.2 Working with processes
  #  c(["lib/ch_5.ex"]); Ch5.test_ch5_1()
  def test_ch5_1() do
    run_query = fn query ->
      Process.sleep(1000)
      "#{query} result"
    end


    out = run_query.("Query 1")
    IO.puts(out)

    out = Enum.map(1..5, fn ind ->
      run_query.("Query #{ind}")
    end)
    IO.inspect(out)

    true
  end
  ## 5.2.1 Creating processes
  #  c(["lib/ch_5.ex"]); Ch5.test_ch5_2()
  def test_ch5_2() do
    run_query = fn query ->
      Process.sleep(1000)
      "#{query} result"
    end

    p = spawn(fn ->
      out = run_query.("Query 1")
      IO.inspect(out)
    end)
    IO.inspect(p)

    async_query = fn query ->
      spawn(fn ->
        out = run_query.(query)
        IO.puts(out)
      end)
    end
    p = async_query.("Query 1")
    IO.inspect(p)

    out = Enum.map(1..5, fn ind ->
      async_query.("Query #{ind}")
    end)
    IO.inspect(out)

    true
  end
  ## 5.2.2 Message passing
  #  c(["lib/ch_5.ex"]); Ch5.test_ch5_3()
  def test_ch5_3() do
    run_query = fn query ->
      Process.sleep(1000)
      "#{query} result"
    end

    async_query = fn query ->
      caller = self()
      spawn(fn ->
        out = run_query.(query)
        send(caller, {:query_result, out})
      end)
    end

    IO.puts("Function version")
    Enum.each(1..5, fn ind -> async_query.("query #{ind}") end)

    get_result = fn ->
      receive do
        {:query_result, result} -> result
      end
    end
    results = Enum.map(1..5, fn _ -> get_result.() end)
    IO.inspect(results)

    # pipe version
    IO.puts("Pipe version")
    out = 1..5
    |> Enum.map(fn ind -> async_query.("query #{ind}") end) # pids
    |> Enum.map(fn _ -> get_result.() end)
    IO.inspect(out)

    true
  end

  ## 5.3 Stateful server processes

  ## 5.3.1 Server processes
  #  c(["lib/ch_5.ex"]); Ch5.test_ch5_4()
  def test_ch5_4() do
    server_pid = DatabaseServer.start()

    DatabaseServer.run_async(server_pid, "query 1")
    assert DatabaseServer.get_result() == "query 1 result"

    DatabaseServer.run_async(server_pid, "query 2")
    assert DatabaseServer.get_result() == "query 2 result"

  end

  ## 5.3.2 Keeping a process state
  #  c(["lib/ch_5.ex"]); Ch5.test_ch5_5()
  def test_ch5_5() do
    server_pid = DatabaseServer.start()
    IO.puts("Server:")
    IO.inspect(server_pid)

    DatabaseServer.run_async(server_pid, "query 1")
    out = DatabaseServer.get_result()
    IO.inspect(out)

    DatabaseServer.run_async(server_pid, "query 2")
    out = DatabaseServer.get_result()
    IO.inspect(out)

    DatabaseServer.stop(server_pid)

    #out = DatabaseServer.run_async(server_pid, "query 2")

    true
  end

  ## 5.3.3 Mutable state
  #  c(["lib/ch_5.ex"]); Ch5.test_ch5_6()
  def test_ch5_6() do
    pid = Calculator.start()

    assert Calculator.value(pid) == 0
    Calculator.add(pid, 10)
    assert Calculator.value(pid) == 10
    Calculator.sub(pid, 5)
    assert Calculator.value(pid) == 5
    Calculator.mul(pid, 3)
    assert Calculator.value(pid) == 15
    Calculator.div(pid, 5)
    assert Calculator.value(pid) == 3

    out = Calculator.stop(pid)
    assert out == :stop

    true
  end

  def collect_titles(entries) do
    titles = Enum.reduce(entries, MapSet.new(), fn entry, acc ->
      MapSet.put(acc, entry[:title])
    end)
    titles
  end
  ## 5.3.4 Complex states
  #  c(["lib/ch_5.ex"]); Ch5.test_ch5_7()
  def test_ch5_7() do
    todo_server = TodoServer.start()

    TodoServer.add_entry(todo_server, %{date: ~D[2023-12-19], title: "Dentist"})
    # Test
    entries = TodoServer.entries(todo_server, ~D[2023-12-19])
    assert collect_titles(entries) == MapSet.new(["Dentist"])

    TodoServer.add_entry(todo_server, %{date: ~D[2023-12-20], title: "Shopping"})
    TodoServer.add_entry(todo_server, %{date: ~D[2023-12-19], title: "Movie"})

    # Test
    entries = TodoServer.entries(todo_server, ~D[2023-12-19])
    assert collect_titles(entries) == MapSet.new(["Dentist", "Movie"])
    entries = TodoServer.entries(todo_server, ~D[2023-12-20])
    assert collect_titles(entries) == MapSet.new(["Shopping"])

    TodoServer.stop(todo_server)
  end
  ## 5.3.5 Registered processes
  #  c(["lib/ch_5.ex"]); Ch5.test_ch5_8()
  # See TodoServer2 for modification that makes this work in iex
  def test_ch5_8() do
    TodoServer2.start() |> Process.register(:todo_server)

    TodoServer2.add_entry(%{date: ~D[2023-12-19], title: "Dentist"})
    # Test
    entries = TodoServer2.entries(~D[2023-12-19])
    assert Ch5.collect_titles(entries) == MapSet.new(["Dentist"])

    TodoServer2.add_entry(%{date: ~D[2023-12-20], title: "Shopping"})
    TodoServer2.add_entry(%{date: ~D[2023-12-19], title: "Movie"})

    # Test
    entries = TodoServer2.entries(~D[2023-12-19])
    assert Ch5.collect_titles(entries) == MapSet.new(["Dentist", "Movie"])
    entries = TodoServer2.entries(~D[2023-12-20])
    assert Ch5.collect_titles(entries) == MapSet.new(["Shopping"])

    TodoServer2.stop()
  end
  ## 5.4 Runtime considerations
  ## 5.4.1 A process is sequential
  ## 5.4.2 unlimited process mailboxes
  ## 5.4.3 Shared-nothing concurrency
  ## 5.4.4 Scheduler inner workings
end
defmodule Ch5.Calculator do
  def start() do
    spawn(fn -> loop(0) end)
  end
  def stop(pid) do
    send(pid, :stop)
  end

  def value(server_pid) do
    send(server_pid, {:value, self()})
    receive do
      {:response, value} -> value
    end
  end
  def add(server_pid, value), do: send(server_pid, {:add, value})
  def sub(server_pid, value), do: send(server_pid, {:sub, value})
  def mul(server_pid, value), do: send(server_pid, {:mul, value})
  def div(server_pid, value), do: send(server_pid, {:div, value})

  defp loop(), do: true

  defp loop(value) do
    out = receive do
      :stop -> loop()
      {:value, caller} ->
        send(caller, {:response, value})
        value
      {:add, v} -> value + v
      {:sub, v} -> value - v
      {:mul, v} -> value * v
      {:div, v} -> value / v
      error ->
        IO.puts("Invalid request #{inspect error}")
        value
    end

    loop(out)
  end


end
defmodule Ch5.DatabaseServer do
  def run_async(server_pid, query) do
    send(server_pid, {:run_query, self(), query})
  end
  def stop(server_pid) do
    send(server_pid, {:stop})
  end

  def get_result() do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end


  # 5.3.1
  # def start() do
  #   spawn(&loop/0)
  # end

  # defp loop() do
  #   receive do
  #     {:run_query, caller, query} ->
  #       out = run_query(query)
  #       send(caller, {:query_result, out})
  #   end

  #   loop()
  # end

  # defp run_query(query) do
  #   Process.sleep(1000)
  #   "#{query} result"
  # end

  # 5.3.2
  def start() do
    spawn(fn ->
      connection = :rand.uniform(1000) # simulate database connection
      loop(connection)
    end)
  end

  defp loop() do
    IO.puts("Server stopped")
    :ok
  end

  defp loop(connection) do
    receive do
      {:run_query, caller_pid, query} ->
        out = run_query(connection, query)
        #IO.inspect(out)
        send(caller_pid, {:query_result, out})
      {:stop} -> loop()
    end

    loop(connection)
  end

  defp run_query(connection, query) do
    Process.sleep(1000)
    "Connection #{connection}: #{query} result"
  end
end

defmodule TodoServer do
  def start do
    spawn(fn -> loop(TodoList.new()) end)
  end
  def stop(server_pid) do
    send(server_pid, :stop)
  end

  def add_entry(pid, entry) do
    send(pid, {:add_entry, entry})
  end
  def entries(server, date) do
    send(server, {:entries, self(), date})
    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end


  defp loop(:stop), do: true
  defp loop(todo_list) do
    todo_list_out = receive do
      :stop -> loop(:stop)
      message -> proc_message(todo_list, message)
    end

    loop(todo_list_out)
  end
  defp proc_message(todo_list, {:add_entry, entry}) do
    {_id, todo_list} = TodoList.add_entry(todo_list, entry)
    todo_list
  end
  defp proc_message(todo_list, {:entries, client, date}) do
    send(client, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end

defmodule TodoServer2 do
  def start do
    pid = spawn(fn ->
      #Process.register(self(), :todo_server) # does not work in iex
      loop(TodoList.new())
    end)
    #Process.register(pid, :todo_server)
    pid
  end
  def stop() do
    send(:todo_server, :stop)
  end

  def add_entry(entry) do
    send(:todo_server, {:add_entry, entry})
  end
  def entries(date) do
    send(:todo_server, {:entries, self(), date})
    receive do
      {:todo_entries, entries} -> entries
    after
      5000 -> {:error, :timeout}
    end
  end


  defp loop(:stop), do: true
  defp loop(todo_list) do
    todo_list_out = receive do
      :stop -> loop(:stop)
      message -> proc_message(todo_list, message)
    end

    loop(todo_list_out)
  end
  defp proc_message(todo_list, {:add_entry, entry}) do
    {_id, todo_list} = TodoList.add_entry(todo_list, entry)
    todo_list
  end
  defp proc_message(todo_list, {:entries, client, date}) do
    send(client, {:todo_entries, TodoList.entries(todo_list, date)})
    todo_list
  end
end

## Copied from todo_list.ex
defmodule TodoList do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries, %TodoList{},
      fn entry, todo_list ->
        add_entry(todo_list, entry)
      end
    )
  end

  @spec add_entry(TodoList, map()) :: TodoList
  def add_entry(todo_list, entry) do
    # add id to entry
    id = todo_list.next_id
    entry = Map.put(entry, :id, id)
    new_entries = Map.put(todo_list.entries, id, entry)

    todo_list_out = %TodoList{todo_list |
      entries: new_entries,
      next_id: todo_list.next_id + 1
    }

    {id,todo_list_out}
  end

  def entries(todo_list, date) do
    todo_list.entries |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, entry_id, update_fn) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        new_entry = update_fn.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    Map.delete(todo_list, entry_id)
  end
end
