## 4.1.1 Basic abstraction
defmodule TodoList do
  #import MultiDict
  #def new(), do: %{}
  def new(), do: MultiDict.new()
  def add_entry(todo_list, date, title) do
    # Map.update(todo_list, date, [title],
    #   fn titles -> [title | titles] end
    # )
    MultiDict.add(todo_list, date, title)
  end
  def entries(todo_list, date) do
    #Map.get(todo_list, date, [])
    MultiDict.get(todo_list, date)
  end
end
