## Open in Erlang window
# iex --werl
#
## Fix font not displayed properly
# chcp 65001 # from https://groups.google.com/g/elixir-lang-talk/c/C6YrOKQ81PI
# iex
#
## Ignore warning, https://elixirforum.com/t/how-to-disable-redefining-warning/53342
# Code.put_compiler_option(:ignore_module_conflict, true)

defmodule Ch6 do
  import ExUnit.Assertions
  ## 6 Generic server processes
  ## 6.1 Building a generic server process
  ## 6.1.1 Plugging in with modules
  ## 6.1.2 Implementing the generic code
  ## 6.1.3 Using the generic abstraction
  #  c(["lib/ch_6.ex"]); Ch6.test_ch6_1()
  def test_ch6_1() do
    pid = ServerProcess.start(KeyValueStore)
    ServerProcess.call(pid, {:put, :some_key, :some_value})
    out = ServerProcess.call(pid, {:get, :some_key})
    assert out == :some_value

    # Use convenience methods
    pid = KeyValueStore.start()
    KeyValueStore.put(pid, :some_key, :some_value)
    out = KeyValueStore.get(pid, :some_key)
    assert out == :some_value

    true
  end
end

defmodule ServerProcess do
  def call(server_pid, request) do
    send(server_pid, {request, self()})
    receive do
      {:response, response} -> response
    end
  end
  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end
  defp loop(callback_module, current_state) do
    receive do
      {request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)
    end
  end
end

defmodule KeyValueStore do
  def init(), do: %{}
  def handle_call({:get, key}, db) do
    {Map.get(db, key), db}
  end
  def handle_call({:put, key, value}, db) do
    {:ok, Map.put(db, key, value)}
  end

  def start() do
    ServerProcess.start(KeyValueStore)
  end
  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end
  def put(pid, key, value) do
    ServerProcess.call(pid, {:put, key, value})
  end
end
