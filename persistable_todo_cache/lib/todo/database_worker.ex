## Listing 7.7
defmodule Todo.DatabaseWorker do
  use GenServer

  @db_folder "./persist"

  def start() do
    init_arg = nil
    GenServer.start(__MODULE__, init_arg, name: __MODULE__)
  end
  def init(init_arg) do
    File.mkdir_p!(@db_folder)
    {:ok, init_arg}
  end
  def store(key, data) do
    GenServer.cast(__MODULE__, {:store, key, data})
  end
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end
  def handle_cast({:store, key, data}, state) do
    key |> file_name() |> File.write!(:erlang.term_to_binary(data))
    {:noreply, state}
  end
  def handle_call({:get, key}, _from, state) do
    data = case File.read(file_name(key)) do
      {:ok, bin} -> :erlang.binary_to_term(bin)
      _ -> nil
    end
    {:reply, data, state}
  end
  defp file_name(key) do
    Path.join(@db_folder, to_string(key))
  end
end
