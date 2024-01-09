defmodule Todo.Server do
  use GenServer

  @impl true
  def init({list_name, nil}) do
    {:ok, {list_name, nil}, {:continue, :init}}
  end
  def start(list_name) do
    #todo_list = Todo.List.new()
    # Listing 7.10
    GenServer.start(__MODULE__, {list_name, nil})
  end

  def add_entry(pid, entry) do
    GenServer.cast(pid, {:add_entry, entry})
  end
  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end
  @impl true
  def handle_cast({:add_entry, entry}, {list_name, todo_list}) do
    {_id, todo_list} = Todo.List.add_entry(todo_list, entry)
    Todo.Database.store(list_name, todo_list)
    {:noreply, {list_name,todo_list}}
  end
  @impl true
  def handle_call({:entries, date}, {_request_id, _caller}, {list_name,todo_list}) do
    {:reply, Todo.List.entries(todo_list, date), {list_name,todo_list}}
  end
  # Called due to {:continue, :init} in start()
  @impl true
  def handle_continue(:init, {list_name, nil}) do
    todo_list = Todo.Database.get(list_name) || Todo.List.new()
    {:noreply, {list_name, todo_list}}
  end
end
