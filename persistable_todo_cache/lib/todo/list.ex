defmodule Todo.List do
  defstruct next_id: 1, entries: %{}

  def new(entries \\ []) do
    Enum.reduce(
      entries, %Todo.List{},
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

    todo_list_out = %Todo.List{todo_list |
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
        %Todo.List{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    Map.delete(todo_list, entry_id)
  end
end
