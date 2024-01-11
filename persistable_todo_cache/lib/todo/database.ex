## Listing 7.7
defmodule Todo.Database do
  use GenServer

  @db_folder "./persist"

  def start() do
    init_arg = nil
    GenServer.start(__MODULE__, init_arg, name: __MODULE__)
  end
  def init(_) do
    File.mkdir_p!(@db_folder)
    worker_db = Enum.reduce(0..2, %{}, fn i,db ->
      Map.put(db, i, Todo.DatabaseWorker.start(@db_folder))
    end)
    # Enum.each(0..2, fn ind ->
    #   worker_db = Map.put(worker_db, ind, Todo.DatabaseWorker.start(@db_folder))
    # end)
    {:ok, worker_db}
  end
  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end
  def handle_cast({:store, key, data}, state) do
    #key |> file_name() |> File.write!(:erlang.term_to_binary(data))
    {:ok, pid} = choose_worker(key, state)
    Todo.DatabaseWorker.store(pid, key, data)
    {:noreply, state}
  end
  def handle_call({:get, key}, _from, state) do
    # data = case File.read(file_name(key)) do
    #   {:ok, bin} -> :erlang.binary_to_term(bin)
    #   _ -> nil
    # end
    {:ok, pid} = choose_worker(key, state)
    data = Todo.DatabaseWorker.get(pid, key)
    {:reply, data, state}
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
