defmodule FunctionTest do
  # https://elixirschool.com/en/lessons/basics/functions
  use ExUnit.Case

  test "Anonymous Functions" do
    sum = fn(x,y) -> x+y end
    assert 5 = sum.(2,3) # notice the dot

    # shorthand version
    sum  = &(&1 + &2)
    assert 7 = sum.(2,5) # notice the dot
  end

  test "Pattern Matching" do
    f = fn
      {:ok, result} -> result
      :error -> :ERROR
    end

    assert "Hello" = f.({:ok, "Hello"})
    assert :ERROR = f.(:error)
  end



  def hello2(name, language_code \\ "en") when is_binary(name) do
    case language_code do
      "es" -> "Hola, #{name}"
      _    -> "Hello, #{name}"
    end

    #"Hello, " <> name
  end

  def hello(), do: "Hello, there!"
  def hello(name) when is_binary(name), do: "Hello, " <> name
  def hello(person = %{name: name}) when is_map(person), do: "Hello, #{name}"
  def hello(names) when is_list(names) do
    names_str = Enum.join(names, ", ")
    hello(names_str)
  end
  def hello(x,y), do: "Hello, #{x} and #{y}"


  def length_of([]), do: 0
  def length_of([_head | tail]), do: 1 + length_of(tail)

  test "Named Functions" do
    assert "Hello, Sean" = hello("Sean")

    assert 0 = length_of([])
    assert 5 = length_of([1,2,3,4,5])

    ## Function Naming and Arity
    assert "Hello, there!" = hello()
    assert "Hello, Sean" = hello("Sean")
    assert "Hello, Sean and Elle" = hello("Sean", "Elle")

    ## Function and Pattern Matching
    assert "Hello, Elle" = hello(%{name: "Elle", phone: "111-111-1111"})
    assert_raise FunctionClauseError, fn -> hello(%{phone: "111-111-1111"}) end

    ## Private Functions
    # define private function with
    # defp

    ## Guards
    # "when" in fn definition
    assert "Hello, Elle, Sean" = hello(["Elle", "Sean"])

    ## Default Arguments
    # see hello2(name)
    assert "Hola, Elle" = hello2("Elle", "es")

    ## function head
    # def hello(names, language_code \\ "en")
    # def hello(names, language_code) when is_list(names) do
    #   ...
    # end
    # def hello(name, language_code) when is_binary(name) do
    #   ...
    # end

  end
end
