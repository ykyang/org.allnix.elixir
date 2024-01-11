defmodule Todo.Cache do
  use GenServer


  def start() do
    # :: {:ok, pic_cache}
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, list_name) do
    # :: pid_server
    GenServer.call(cache_pid, {:server_process, list_name})
  end

  @impl true # Call by GenServer.call/2
  def handle_call({:server_process, todo_list_name}, _from, state) do
    # :: {:reply, out, state}
    server_db = state
    case Map.fetch(server_db, todo_list_name) do
      ## Return existing server
      {:ok, todo_server} -> {:reply, todo_server, server_db}
      ## Create and return a new server
      :error ->
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        server_db = Map.put(server_db, todo_list_name, new_server)
        {:reply, new_server, server_db}
    end
  end

  @impl true
  def init(_) do # Call by GenServer.start/2
    # :: {:ok, state}
    server_db = %{} # %{todo_list_name: pid_server}
    Todo.Database.start() # Database
    {:ok, server_db}
  end
end
