defmodule ControlTest do
  # https://elixirschool.com/en/lessons/basics/control_structures
  use ExUnit.Case

  test "if and unless" do
    # "if" is a macro
    if String.valid?("Hello") do
      assert true
    else
      assert false
    end

    # "unless" is a macro
    # unless = if not
    unless is_integer("hello") do
      assert true
    else
      assert false
    end
  end

  test "case" do
    cond = {:ok, "Hello World"}
    out = case cond do
      {:ok, result} -> result
      {:error} -> "ERROR"
      _ -> "Catch all"
    end

    assert out == "Hello World"

    # no match raise a CaseClauseError

    # use pin ^ operator
    #pie = 3.14
    out = case "cherry pie" do
      #^pie -> "Not so tasty" # match to pie=3.14
      pie -> "I bet #{pie} is tasty" # pie = "cherry pie"
    end

    assert out == "I bet cherry pie is tasty"

    # Guard clause
    out = case {1,2,3} do
      {1,x,3} when x > 0 -> "Match"
      _ -> "Not match"
    end
    assert out == "Match"
  end

  test "cond" do
    # else if
    out = cond do
      2 + 2 == 5 -> false
      2 * 2 == 3 -> false
      1 + 1 == 2 -> true
    end
    assert out
    # catch all
    out = cond do
      7 + 1 == 0 -> false
      true -> true # catch all
    end
    assert out
  end

  test "with" do
    # "with" run through all matching
    user = %{first: "Sean", last: "Callan"}
    out = with {:ok, first} <- Map.fetch(user, :first),
               {:ok, last} <- Map.fetch(user, :last)
    do
      "#{last}, #{first}"
    end
    assert out == "Callan, Sean"

    # short circuit if error, and return the error
    out = with {:ok, middle} <- Map.fetch(user, :middle), # :error
               {:ok, _first} <- Map.fetch(user, :first),
               {:ok, _last} <- Map.fetch(user, :last)
    do
      middle
    end
    assert :error = out

    # else
    out = with {:ok, middle} <- Map.fetch(user, :middle), # :error
               {:ok, _first} <- Map.fetch(user, :first),
               {:ok, _last} <- Map.fetch(user, :last)
    do
      middle
    else
      :error -> {:error, "Middle name not found"}
      _ -> {:error, "Unknow error"}
    end
    assert out == {:error, "Middle name not found"}
  end
end
