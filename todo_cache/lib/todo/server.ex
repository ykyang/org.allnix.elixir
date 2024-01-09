defmodule Todo.Server do
  use GenServer

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end
  def start() do
    GenServer.start(__MODULE__, Todo.List.new())
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end
  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end
  @impl true
  def handle_cast({:add_entry, entry}, state) do
    {_id, state2} = Todo.List.add_entry(state, entry)
    {:noreply, state2}
  end
  @impl true
  def handle_call({:entries, date}, {_request_id, _caller}, state) do
    {:reply, Todo.List.entries(state, date), state}
  end
end
