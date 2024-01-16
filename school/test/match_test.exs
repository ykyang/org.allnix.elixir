defmodule MatchTest do
  # https://elixirschool.com/en/lessons/basics/pattern_matching
  use ExUnit.Case

  test "Match Operator" do
    x = 1
    assert 1 == (1=x)
    # assert_raise MatchError, fn -> 2 = x end

    list = [1,2,3]
    assert list == ([1,2,3] = list)
    # assert_raise MatchError, fn -> [] = list end

    [1 | tail] = list
    assert [2,3] == tail

    {:ok, value} = {:ok, "Successful!"}
    assert value == "Successful!"

    # assert_raise MatchError, fn -> {:ok, value} = {:error} end
  end

  test "Pin Operator" do
    # pin oerator ^, compare the value of a variable instead rebinding to it
    x = 1
    {y, ^x} = {2, 1} # value of x is used to match
    assert y == 2

    # assert_raise MatchError, fn -> {y, ^x} = {2, 1} end

    # map
    key = "hello"
    %{^key => value} = %{"hello" => "world"}
    assert value == "world"

    greeting = "Hello"
    greet = fn
      (^greeting, name) -> "Hi #{name}"
      (greeting, name) -> "#{greeting}, #{name}"
    end

    assert greet.("Hello", "Sean") == "Hi Sean"
    assert greet.("Mornin'", "Sean") == "Mornin', Sean"
    assert greeting == "Hello"
  end
end
