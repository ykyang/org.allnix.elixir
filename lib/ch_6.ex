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

  def collect_titles(entries) do
    titles = Enum.reduce(entries, MapSet.new(), fn entry, acc ->
      MapSet.put(acc, entry[:title])
    end)
    titles
  end

  ## 6.2.8 Exercise: GenServer-powered to-do server
  #  c(["lib/ch_6.ex"]); Ch6.test_ch6_5()
  def test_ch6_5() do
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

  ## Use TodoServer2 which uses GenServer
  #  c(["lib/ch_6.ex"]); Ch6.test_ch6_6()
  def test_ch6_6() do
    tsr = TodoServer2
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
  use GenServer

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end
  def start() do
    GenServer.start(TodoServer2, TodoList.new())
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end
  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end
  @impl true
  def handle_cast({:add_entry, entry}, state) do
    {_id, state2} = TodoList.add_entry(state, entry)
    {:noreply, state2}
  end
  @impl true
  def handle_call({:entries, date}, {_request_id, _caller}, state) do
    {:reply, TodoList.entries(state, date), state}
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
