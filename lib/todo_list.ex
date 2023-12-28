## 4.1.1 Basic abstraction
defmodule TodoList do
  #import MultiDict
  #def new(), do: %{}
  def new(), do: MultiDict.new()
  # def add_entry(todo_list, date, title) do
  #   MultiDict.add(todo_list, date, title)
  # end
  def add_entry(todo_list, entry) do
    MultiDict.add(todo_list, entry.date, entry)
  end
  def entries(todo_list, date) do
    #Map.get(todo_list, date, [])
    MultiDict.get(todo_list, date)
  end
end
