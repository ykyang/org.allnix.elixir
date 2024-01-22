defmodule ComprehensionsTest do
  # https://elixirschool.com/en/lessons/basics/comprehensions
  use ExUnit.Case
  import Integer

  test "Basics" do
    # list
    list = [1,2,3,4,5]
    out = for x <- list, do: x*x
    assert [1,4,9,16,25] = out

    # Keyword list
    list = [one: 1, two: 2, three: 3]
    out = for {_key,value} <- list, do: value
    assert [1,2,3] = out

    # Maps
    db = %{a: "A", b: "B", c: "C"}
    out = for {_k,v} <- db, do: v
    assert ~w/A B C/ = out

    # binaries
    # <<>> binary stream
    out = for <<c <- "hello">>, do: <<c>>
    assert ~w/h e l l o/ = out

    out = for c <- ~c"hello", do: <<c>>
    assert ~w/h e l l o/ = out

    # pattern
    # skip :error
    list = [ok: "A", error: "B", ok: "C"]
    out = for {:ok, v} <- list, do: v
    assert ~w/A C/ = out

    # nested
    out = for x <- ["A", "B"], y <- ["C", "D"], do: x <> y
    assert ~w/AC AD BC BD/ = out
  end

  test "Filters" do
    # filter: is_even
    out = for x <- 1..10, is_even(x), do: x
    assert [2,4,6,8,10] = out
    # multiple filter
    out = for x <- 1..10, is_odd(x), rem(x,3) == 0, do: x
    assert [3,9] = out

    ## :into
    # insert into map
    out = for {k,v} <- [one: 1, two: 2, three: 3], into: %{}, do: {k,v}
    assert out == %{one: 1, two: 2, three: 3}

    out = for c <- ~c/Hello/, into: "", do: <<c>>
    assert "Hello" == out
  end
end
