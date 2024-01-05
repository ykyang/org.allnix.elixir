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
    out = KeyValueStore.put(pid, :some_key, :some_value)
    assert out == :ok
    out = KeyValueStore.get(pid, :some_key)
    assert out == :some_value

    true
  end
  ## 6.1.4 Supporting asynchronous requests
  #  c(["lib/ch_6.ex"]); Ch6.test_ch6_2()
  def test_ch6_2() do
    pid = KeyValueStore2.start()
    _out = KeyValueStore2.put(pid, :some_key, :some_value)
    ## The following should not be tested.  This is internal data structure.
    # assert _out == {:cast, {:put, :some_key, :some_value}}
    out = KeyValueStore2.get(pid, :some_key)
    assert out == :some_value

    true
  end
  ## 6.2 Using GenServer
  ## 6.2.1 OTP behaviours
  ## 6.2.2 Plugging into GenServer
  ## 6.2.3 Handling requests
  #  c(["lib/ch_6.ex"]); pid = Ch6.test_ch6_3()
  #  GenServer.stop(pid)
  def test_ch6_3() do
    kvs = KeyValueStore3
    {:ok, pid} = kvs.start()
    :ok = kvs.put(pid, :some_key, :some_value)
    :some_value = kvs.get(pid, :some_key)

    pid
  end
  ## 6.2.4 Handling plain messages
  # See test_ch6_3()
  ## 6.2.5 Other GenServer features
  ## Compile-time checking
  ##   @impl
  ## Name registration
  #  c(["lib/ch_6.ex"]); Ch6.test_ch6_4()
  def test_ch6_4() do
    kvs = KeyValueStore4
    {:ok, pid} = kvs.start()
    :ok = kvs.put(:some_key, :some_value)
    :some_value = kvs.get(:some_key)

    GenServer.stop(pid)
  end
  ## Stopping the server
  ## 6.2.6 Process lifecycle
  ## 6.2.7 OTP-compliant processes
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

defmodule ServerProcess2 do
  def call(server_pid, request) do
    send(server_pid, {:call, request, self()})
    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
    send(server_pid, {:cast, request})
  end

  def start(callback_module) do
    spawn(fn ->
      initial_state = callback_module.init()
      loop(callback_module, initial_state)
    end)
  end

  defp loop(callback_module, current_state) do
    receive do
      {:call, request, caller} ->
        {response, new_state} = callback_module.handle_call(request, current_state)
        send(caller, {:response, response})
        loop(callback_module, new_state)
      {:cast, request} ->
        new_state = callback_module.handle_cast(request, current_state)
        loop(callback_module, new_state)
    end

  end
end
defmodule KeyValueStore2 do
  def init(), do: %{}
  def handle_call({:get, key}, db) do
    {Map.get(db, key), db}
  end
  # def handle_call({:put, key, value}, db) do
  #   {:ok, Map.put(db, key, value)}
  # end
  def handle_cast({:put, key, value}, db) do
    Map.put(db, key, value)
  end

  def start() do
    ServerProcess2.start(KeyValueStore2)
  end
  def get(pid, key) do
    ServerProcess2.call(pid, {:get, key})
  end
  def put(pid, key, value) do
    ServerProcess2.cast(pid, {:put, key, value})
  end
end

defmodule KeyValueStore3 do
  use GenServer
  # KeyValueStore.__info__(:functions)

  ## default implementation
  @impl true
  def init(init_arg) do
    :timer.send_interval(5000, :cleanup)
    {:ok, init_arg}
  end
  def start() do
    GenServer.start(KeyValueStore3, %{}) # 2nd arg passed to init(_)
  end

  # def init(_) do # why not use the default one
  #   initial_state = %{}
  #   {:ok, initial_state}
  # end
  # def start() do
  #   GenServer.start(KeyValueStore3, nil) # 2nd arg passed to init(_)
  # end

  @impl true
  def handle_cast({:put, key, value}, state) do
    state2 = Map.put(state, key, value)
    {:noreply, state2}
  end

  @impl GenServer
  def handle_call({:get, key}, {_request_id, _caller}, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    IO.puts("Performing cleanup...")
    {:noreply, state}
  end

  def put(pid, key, value) do
    GenServer.cast(pid, {:put, key, value})
  end
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end
end

defmodule KeyValueStore4 do
  use GenServer
  @impl true
  def init(init_arg) do
    {:ok, init_arg} # {:stop, "reason"}
  end
  def start() do
    # 3rd arg is to register the process with atom
    # use module name, __MODULE__ == KeyValueStore4
    GenServer.start(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    state2 = Map.put(state, key, value)
    {:noreply, state2}
  end

  @impl GenServer
  def handle_call({:get, key}, {_request_id, _caller}, state) do
    {:reply, Map.get(state, key), state}
  end

  @impl true
  def handle_info(:cleanup, state) do
    IO.puts("Performing cleanup...")
    {:noreply, state}
  end

  def put(key, value) do
    # 1st is pid replaced by registered atom
    GenServer.cast(__MODULE__, {:put, key, value})
  end
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end
end
