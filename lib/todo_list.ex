## 4.1.1 Basic abstraction
defmodule TodoList do
  #import MultiDict

  ## 4.1.3
  #def new(), do: %{}
  # def add_entry(todo_list, date, title) do
  #   MultiDict.add(todo_list, date, title)
  # end
  # def entries(todo_list, date) do
  #   Map.get(todo_list, date, [])
  # end

  ## 4.1.4
  # def new(), do: MultiDict.new()
  # def add_entry(todo_list, entry) do
  #   MultiDict.add(todo_list, entry.date, entry)
  # end
  # def entries(todo_list, date) do
  #   MultiDict.get(todo_list, date)
  # end

  ## 4.2.1
  defstruct next_id: 1, entries: %{}
  def new(), do: %TodoList{}

  @spec add_entry(TodoList, map()) :: TodoList
  def add_entry(todo_list, entry) do
    # add id to entry
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(
      todo_list.entries, todo_list.next_id, entry
    )

    %TodoList{todo_list |
      entries: new_entries,
      next_id: todo_list.next_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end
end
