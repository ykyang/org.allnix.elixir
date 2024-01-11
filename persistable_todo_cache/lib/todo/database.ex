## Listing 7.7
defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start() do
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end
  def init(_) do
    File.mkdir_p!(@db_folder)
    worker_db = Enum.reduce(0..2, %{}, fn i,db ->
      Map.put(db, i, Todo.DatabaseWorker.start(@db_folder))
    end)
    {:ok, worker_db} # {:ok, state}
  end
  def store(key, data) do # (list_name, list)
    GenServer.cast(__MODULE__, {:store, key, data})
  end
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end
  def handle_cast({:store, key, data}, worker_db) do
    # ({:store, key, data}, state)
    {:ok, pid} = choose_worker(key, worker_db)
    Todo.DatabaseWorker.store(pid, key, data)
    {:noreply, worker_db} # {:noreply, state}
  end
  def handle_call({:get, key}, _from, worker_db) do
    # ({:get, key}, _from, state)
    {:ok, pid} = choose_worker(key, worker_db)
    data = Todo.DatabaseWorker.get(pid, key)
    {:reply, data, worker_db}
  end
  # defp file_name(key) do
  #   Path.join(@db_folder, to_string(key))
  # end
  defp choose_worker(key, worker_db) do
    key = :erlang.phash2(key,3)
    # TODO, error checking
    Map.get(worker_db, key)
  end
end
