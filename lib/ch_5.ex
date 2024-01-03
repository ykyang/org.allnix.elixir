defmodule Ch5 do
alias Ch5.DatabaseServer

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

  ## 5.3 Stateful server process
  #  c(["lib/ch_5.ex"]); Ch5.test_ch5_4()
  def test_ch5_4() do
    server_pid = DatabaseServer.start()

    DatabaseServer.run_async(server_pid, "query 1")
    assert DatabaseServer.get_result() == "query 1 result"

    DatabaseServer.run_async(server_pid, "query 2")
    assert DatabaseServer.get_result() == "query 2 result"

  end

end

defmodule Ch5.DatabaseServer do
  def start() do
    spawn(&loop/0)
  end

  def run_async(server_pid, query) do
    send(server_pid, {:run_query, self(), query})
  end

  def get_result() do
    receive do
      {:query_result, result} -> result
    after
      5000 -> {:error, :timeout}
    end
  end


  defp loop() do
    receive do
      {:run_query, caller, query} ->
        out = run_query(query)
        send(caller, {:query_result, out})
    end

    loop()
  end

  defp run_query(query) do
    Process.sleep(1000)
    "#{query} result"
  end

end
