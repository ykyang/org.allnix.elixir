defmodule StringsTest do
  # https://elixirschool.com/en/lessons/basics/strings
  use ExUnit.Case
  test "Strings" do
    # Use << >> to enclose bytes
    str = <<104,101,108,108,111>>
    assert "hello" == str
    assert "hello" = str

    # append <<0>> to show as bytes
    str = str <> <<0>>
    assert <<104,101,108,108,111,0>> == str
  end

  test "Charlists" do
    # ł Unicode is 322
    str = 'hełło'  # single quote
    assert [104, 101, 322, 322, 111] = str
    # IO.inspect(str) # [104, 101, 322, 322, 111]

    # ł UTF-8 is 197, 130
    str = "hełło"
    assert <<104, 101, 197, 130, 197, 130, 111>> == str
    assert <<104, 101, 197, 130, 197, 130, 111>> = str
    #IO.inspect(str) # <<104, 101, 197, 130, 197, 130, 111, 0>>

    str = str <> <<0>>
    #IO.inspect(str) # <<104, 101, 197, 130, 197, 130, 111, 0>>
    assert <<104, 101, 197, 130, 197, 130, 111, 0>> == str
    assert <<104, 101, 197, 130, 197, 130, 111, 0>> = str

    # get codepoint with ?
    assert 90 == ?Z
    assert 65 == ?A
  end

  test "Graphemes and Codepoints" do
    # grapheme single character consists of multiple bytes
    # codepoint single byte
    str = "\u0061\u0301"
    assert ["a", "́"] == String.codepoints str # 2nd char is not empty
    assert ["á"] == String.graphemes(str)
    assert ["á"] == String.graphemes("á")

    assert ["A", "B", "C"] == String.graphemes("ABC")
  end

  test "String Functions" do
    assert 5 == String.length("Hellá")
    assert "Hellá" == String.replace("Hello", "o", "á")
    assert "HHH" == String.duplicate("H",3)
    assert ["Hello", "World"] == String.split("Hello World", " ")
  end

  def anagrams?(a,b) when is_binary(a) and is_binary(b) do
    sort_string(a) == sort_string(b)
  end

  def sort_string(str) do
    String.downcase(str) |> String.graphemes() |> Enum.sort()
  end

  test "Exercise" do
    assert anagrams?("Hello", "ohell")
    assert anagrams?("María", "íMara")
    refute anagrams?("AAA", "ABC")
    assert_raise FunctionClauseError, fn -> anagrams?(123, 456) end
  end
end
