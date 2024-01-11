## Listing 7.7
defmodule Todo.DatabaseWorker do
  use GenServer

  #@db_folder "./persist"

  def start(db_folder) do
    init_arg = db_folder
    GenServer.start(__MODULE__, init_arg)
  end
  def init(init_arg) do
    db_folder = init_arg
    File.mkdir_p!(db_folder)
    {:ok, init_arg}
  end
  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end
  def handle_cast({:store, key, data}, state) do
    db_folder = state
    file_name(db_folder, key) |> File.write!(:erlang.term_to_binary(data))
    {:noreply, state}
  end
  def handle_call({:get, key}, _from, state) do
    db_folder = state
    data = case File.read(file_name(db_folder, key)) do
      {:ok, bin} -> :erlang.binary_to_term(bin)
      _ -> nil
    end
    {:reply, data, state}
  end
  defp file_name(db_folder, key) do
    Path.join(db_folder, to_string(key))
  end
end
