defmodule EnumTest do
  # https://hexdocs.pm/elixir/1.16.0/Enum.html
  use ExUnit.Case
  # Enum.__info__(:functions) -> [all?: 1, all?: 2, ...]

  test "Common Functions" do
    # all?, return true if all true
    list = ["foo", "bar", "hello"]
    assert false == Enum.all?(list, fn(s) -> String.length(s) == 3 end)
    assert true  == Enum.all?(list, fn(s) -> String.length(s) > 1 end)

    # any?, return true if any true
    list = ["foo", "bar", "hello"]
    assert true == Enum.any?(list, fn(s) -> String.length(s) == 5 end)
  end
end
