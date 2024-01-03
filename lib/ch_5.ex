# iex --werl

# chcp 65001 # from https://groups.google.com/g/elixir-lang-talk/c/C6YrOKQ81PI
# iex
# c(["lib/todo_list.ex", "lib/ch_4.ex"])
# Ch4.test_ch4_1()
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
