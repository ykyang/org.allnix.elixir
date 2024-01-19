defmodule PipeTest do
  # https://elixirschool.com/en/lessons/basics/pipe_operator
  use ExUnit.Case

  test "Examples" do
    out = "Elixir rocks" |> String.split()
    assert ["Elixir", "rocks"] = out

    out = "Elixir rocks" |> String.upcase() |> String.split()
    assert ["ELIXIR", "ROCKS"] = out
  end
end
