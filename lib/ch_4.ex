# iex --werl

# chcp 65001 # from https://groups.google.com/g/elixir-lang-talk/c/C6YrOKQ81PI
# iex
# c(["lib/todo_list.ex", "lib/ch_4.ex"])
# Ch4.test_ch4_1()

defmodule MultiDict do
  def new(), do: %{}
  def add(dict, key, value) do
    Map.update(dict, key, [value], fn values -> [value | values] end)
  end
  def get(dict, key) do
    Map.get(dict, key, [])
  end
end

defmodule Fraction do
  defstruct a: nil, b: nil
  def new(a, b) do
    %Fraction{a: a, b: b}
  end
  def value(%Fraction{a: a, b: b}) do
    a / b
  end
  def add(%Fraction{a: a1, b: b1}, %Fraction{a: a2, b: b2}) do
    new(a1*b2 + a2*b1, b2*b1)
  end
end

defmodule Ch4 do
  #import TodoList
  import ExUnit.Assertions
  import File

  ## 4.1.1 Basic abstraction
  # def test_ch4_1() do
  #   ## 4.1.2 Composing abstraction
  #   ## MultiDict
  #   # todo_list = TodoList.new()
  #   # |> TodoList.add_entry(~D[2023-12-19], "Dentist")
  #   # |> TodoList.add_entry(~D[2023-12-20], "Shopping")
  #   # |> TodoList.add_entry(~D[2023-12-19], "Movies")
  #   # assert TodoList.entries(todo_list, ~D[2023-12-19]) == ["Movies", "Dentist"]
  #   # assert TodoList.entries(todo_list, ~D[2023-12-18]) == []


  #   ## 4.1.3 Structuring data with maps
  #   todo_list = TodoList.new()
  #   |> TodoList.add_entry(%{date: ~D[2023-12-19], title: "Dentist" })
  #   |> TodoList.add_entry(%{date: ~D[2023-12-20], title: "Shopping"})
  #   |> TodoList.add_entry(%{date: ~D[2023-12-19], title: "Movies"  })
  #   assert TodoList.entries(todo_list, ~D[2023-12-19]) == [%{date: ~D[2023-12-19], title: "Movies"  }, %{date: ~D[2023-12-19], title: "Dentist" }]
  #   assert TodoList.entries(todo_list, ~D[2023-12-18]) == []
  # end

  ## 4.1.4 Abstracting with structs
  #  c(["lib/todo_list.ex", "lib/ch_4.ex"]); Ch4.test_ch4_2()
  def test_ch4_2() do
    f = %Fraction{a: 1, b: 2}
    assert f.a == 1; assert f.b == 2;
    ## pattern match
    %Fraction{a: u, b: v} = f
    assert u == f.a; assert v == f.b;
    assert %Fraction{} = f
    #assert_raise MatchError, fn -> %Fraction{} = %{a: 1, b: 2} end;
    #catch_error %Fraction{} = %{a: 1, b: 2}

    ## new struct from existing struct
    g = %Fraction{f | b: 4}
    assert g.a == f.a; assert g.b == 4

    f = Fraction.new(1,2)
    assert f == %Fraction{a: 1, b: 2}
    assert Fraction.add(f, Fraction.new(1,4)) == Fraction.new(6, 8)
    assert Fraction.new(6, 8) |> Fraction.value() == 0.75

    true
  end

  ## 4.2 Working with hierarchical data


  #  c(["lib/todo_list.ex", "lib/ch_4.ex"], "lib"); Ch4.test_ch4_3()
  def test_ch4_3() do
    ## 4.2.1
    todo_list = TodoList.new()
    |> TodoList.add_entry(%{date: ~D[2023-12-19], title: "Dentist" })
    |> TodoList.add_entry(%{date: ~D[2023-12-20], title: "Shopping"})
    |> TodoList.add_entry(%{date: ~D[2023-12-19], title: "Movies"  })

    assert TodoList.entries(todo_list, ~D[2023-12-19]) == [
      %{date: ~D[2023-12-19], id: 1, title: "Dentist"},
      %{date: ~D[2023-12-19], id: 3, title: "Movies"}
    ]

    ## 4.2.2
    todo_list = TodoList.update_entry(
      todo_list, 1, &Map.put(&1, :date, ~D[2023-12-20])
    )
    assert TodoList.entries(todo_list, ~D[2023-12-20]) == [
      %{date: ~D[2023-12-20], id: 1, title: "Dentist"},
      %{date: ~D[2023-12-20], id: 2, title: "Shopping"}
    ]

    true
  end

  ## 4.2.3
  #  c(["lib/todo_list.ex", "lib/ch_4.ex"], "lib"); Ch4.test_ch4_4()
  def test_ch4_4() do
    todo_list = %{
      1 => %{date: ~D[2023-12-19], title: "Dentist"},
      2 => %{date: ~D[2023-12-20], title: "Shopping"},
      3 => %{date: ~D[2023-12-19], title: "Movies"}
    }
    assert todo_list[3] == %{date: ~D[2023-12-19], title: "Movies"}

    # compile time
    todo_list = put_in(todo_list[3].title, "Theater")
    assert todo_list[3] == %{date: ~D[2023-12-19], title: "Theater"}

    # dynamic
    path = [3, :title]
    todo_list = put_in(todo_list, path, "Concert")
    assert todo_list[3] == %{date: ~D[2023-12-19], title: "Concert"}

    todo_list = TodoList.delete_entry(todo_list, 3)
    assert todo_list == %{
      1 => %{date: ~D[2023-12-19], title: "Dentist"},
      2 => %{date: ~D[2023-12-20], title: "Shopping"},
    }

    true
  end

  ## 4.2.4
  #  c(["lib/todo_list.ex", "lib/ch_4.ex"], "lib"); Ch4.test_ch4_5()
  def test_ch4_5() do
    entries = [
      %{date: ~D[2023-12-19], title: "Dentist"},
      %{date: ~D[2023-12-20], title: "Shopping"},
      %{date: ~D[2023-12-19], title: "Movies"}
    ]

    todo_list = TodoList.new(entries)

    true
  end

  ## 4.2.5
  #  c(["lib/todo_list.ex", "lib/ch_4.ex"], "lib"); Ch4.test_ch4_6()
  def test_ch4_6() do
    ## todos.csv
    # 2023-12-19,Dentist
    # 2023-12-20,Shopping
    # 2023-12-19,Movies

    todo_list = TodoList.CsvImporter.import("todos.csv")

    assert todo_list == TodoList.new([
      %{date: ~D[2023-12-19], title: "Dentist"},
      %{date: ~D[2023-12-20], title: "Shopping"},
      %{date: ~D[2023-12-19], title: "Movies"}
    ])
    true
  end

  ## 4.3 Polymorphism with protocols

  ## 4.3.1 Protocol basics
  ## 4.3.2 Implementing a protocol
end
