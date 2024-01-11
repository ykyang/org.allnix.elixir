defmodule Todo.Server do
  use GenServer


  def start(list_name) do
    GenServer.start(__MODULE__, list_name)
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  @impl true
  def init(list_name) do # call by GenServer.start/2
    state = {list_name, nil} # {list_name, todo_list}
    cont = {:continue, :init} # make GenServer call handle_continue(:init, state)
    {:ok, state, cont}
  end
  @impl true
  def handle_cast({:add_entry, entry}, {list_name, todo_list}) do
    {_id, todo_list} = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(list_name, todo_list)
    state = {list_name, todo_list}
    {:noreply, state}
  end
  @impl true
  def handle_call({:entries, date}, {_request_id, _caller}, state) do
    {_list_name, todo_list} = state
    out = Todo.List.entries(todo_list, date)
    {:reply, out, state}
  end
  @impl true
  def handle_continue(:init, state) do # Called due to {:continue, :init} in start()
    {list_name, nil} = state
    todo_list = Todo.Database.get(list_name) || Todo.List.new()
    state = {list_name, todo_list}
    {:noreply, state}
  end
end
