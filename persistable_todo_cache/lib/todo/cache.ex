defmodule Todo.Cache do
  use GenServer

  def init(db) do
    Todo.Database.start() # Database
    {:ok, db}
  end
  def start() do
    todo_servers = %{}
    GenServer.start(__MODULE__, todo_servers)
  end
  def handle_call({:server_process, todo_list_name}, _from, todo_servers) do
    case Map.fetch(todo_servers, todo_list_name) do
      {:ok, todo_server} -> # return existing server
        {:reply, todo_server, todo_servers}

      :error -> # Create and return a new server
        {:ok, new_server} = Todo.Server.start(todo_list_name)
        todo_servers = Map.put(todo_servers, todo_list_name, new_server)
        {:reply, new_server, todo_servers}
    end
  end
  def server_process(cache_pid, todo_list_name) do
    GenServer.call(cache_pid, {:server_process, todo_list_name})
  end
end
