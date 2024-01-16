defmodule EnumTest do
  # https://hexdocs.pm/elixir/1.16.0/Enum.html
  use ExUnit.Case
  #import ExUnit.CaptureIO

  # Enum.__info__(:functions) -> [all?: 1, all?: 2, ...]

  test "Common Functions" do
    # all?, return true if all true
    list = ["foo", "bar", "hello"]
    assert false == Enum.all?(list, fn(s) -> String.length(s) == 3 end)
    assert true  == Enum.all?(list, fn(s) -> String.length(s) > 1 end)

    # any?, return true if any true
    list = ["foo", "bar", "hello"]
    assert true == Enum.any?(list, fn(s) -> String.length(s) == 5 end)

    # chunk_every
    list = [1,2,3,4,5,6]
    out = [[1,2], [3,4], [5,6]]
    assert out == Enum.chunk_every(list, 2)

    # chunk_by
    list = ["one", "two", "three", "four", "five"]
    out = [["one", "two"], ["three"], ["four", "five"]]
    assert out == Enum.chunk_by(list, fn(x) -> String.length(x) end)

    list = ["one", "two", "three", "four", "five", "six"]
    out = [["one", "two"], ["three"], ["four", "five"], ["six"]]
    assert out == Enum.chunk_by(list, fn(x) -> String.length(x) end)

    # map_every, always map the 1st element
    list = [1, 2, 3, 4, 5, 6, 7, 8]
    out = [101, 2, 3, 104, 5, 6, 107, 8]
    assert out == Enum.map_every(list, 3, fn x -> x + 100 end)
  end

  test "each" do
    #assert capture_io(fn -> IO.puts("Hello World") end) == "Hello World\n"
    list = ["one", "two", "three"]
    assert :ok == Enum.each(list, fn(_s) -> nil end)
  end

  test "map" do
    list = [0, 1, 2, 3]
    out = [-1, 0, 1, 2]
    assert out == Enum.map(list, fn x -> x - 1 end)
  end

  test "min" do
    assert -1 == Enum.min([5, 3, 0, -1])
    # default min value in case the list is empty
    assert :foo == Enum.min([], fn -> :foo end)
  end

  test "max" do
    assert 5 == Enum.max([5, 3, 0, -1])
    # default max value in case the list is empty
    assert :bar == Enum.max([], fn -> :bar end)
  end

  test "filter" do
    assert [2,4] == Enum.filter([1,2,3,4], fn x -> rem(x,2) == 0 end)
  end

  test "reduce" do
    assert false
  end
end
