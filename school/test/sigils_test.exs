defmodule SigilsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "Sigils Overview" do
    ## Char List
    out = ~c"2 + 7 = #{2+7}"
    assert "2 + 7 = 9" == capture_io(fn -> IO.write(out) end)

    out = ~C"2 + 7 = #{2+7}"
    assert "2 + 7 = \#{2+7}" == capture_io(fn -> IO.write(out) end)

    ## Regular Expressions
    # =~ text based match
    # https://hexdocs.pm/elixir/1.16.0/operators.html
    re = ~r"elixir"
    assert "elixir" =~ re
    refute "Elixir" =~ re
    # Perl Compatible Regular Expressions
    # ignore case
    re = ~r"elixir"i
    assert "elixir" =~ re
    assert "Elixir" =~ re
    # split
    str = "100_000_000"
    out = Regex.split(~r"_", str)
    assert out == ["100", "000", "000"]

    ## String
    str = ~s/Welcome to elixir #{String.downcase "SCHOOL"}/
    assert "Welcome to elixir school" == str
    str = ~S/Welcome to elixir #{String.downcase "SCHOOL"}/
    assert "Welcome to elixir \#{String.downcase \"SCHOOL\"}" == str

    ## Word List
    l = ~w/i love #{'E'}lixir school/
    assert ["i", "love", "Elixir", "school"] = l
    l = ~W/i love #{'E'}lixir school/
    assert ["i", "love", "\#{'E'}lixir", "school"] = l

    ## NaiveDateTeim
    # no timezone
    out = NaiveDateTime.from_iso8601("2024-01-21 14:10:25")
    assert {:ok, ~N(2024-01-21 14:10:25)} = out

    ## DateTime
    # Need to use external package
    # Elixir is not good at DateTime

    # out = DateTime.from_iso8601("2024-01-21 14:10:25", "CST")
    # IO.inspect(out)
    # assert {:ok, ~U(2024-01-21 14:10:25Z), -3600} = out

  end
  def sigil_p(str, []), do: String.upcase(str)
  def sigil_REV(str, []), do: String.reverse(str)
  test "Creating Sigils" do
    assert "ELIXIR SCHOOL" == ~p/elixir school/
    assert "loohcs rixile" == ~REV/elixir school/

  end
end
