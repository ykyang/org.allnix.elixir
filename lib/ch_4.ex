# c(["lib/todo_list.ex", "lib/ch_4.ex"])
# Ch4.test_todolist_1()

defmodule MultiDict do
  def new(), do: %{}
  def add(dict, key, value) do
    Map.update(dict, key, [value], fn values -> [value | values] end)
  end
  def get(dict, key) do
    Map.get(dict, key, [])
  end
end

defmodule Ch4 do
  #import TodoList
  import ExUnit.Assertions

  ## 4.1.1 Basic abstraction
  def test_todolist_1() do
    # todo_list = TodoList.new()
    # |> TodoList.add_entry(~D[2023-12-19], "Dentist")
    # |> TodoList.add_entry(~D[2023-12-20], "Shopping")
    # |> TodoList.add_entry(~D[2023-12-19], "Movies")
    # assert TodoList.entries(todo_list, ~D[2023-12-19]) == ["Movies", "Dentist"]
    # assert TodoList.entries(todo_list, ~D[2023-12-18]) == []


    todo_list = TodoList.new()
    |> TodoList.add_entry(%{date: ~D[2023-12-19], title: "Dentist" })
    |> TodoList.add_entry(%{date: ~D[2023-12-20], title: "Shopping"})
    |> TodoList.add_entry(%{date: ~D[2023-12-19], title: "Movies"  })
    assert TodoList.entries(todo_list, ~D[2023-12-19]) == [%{date: ~D[2023-12-19], title: "Movies"  }, %{date: ~D[2023-12-19], title: "Dentist" }]
    assert TodoList.entries(todo_list, ~D[2023-12-18]) == []

  end
  ## 4.1.2 Composing abstraction
  ## MultiDict
  ## 4.1.3 Structuring data with maps


end
