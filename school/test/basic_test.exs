defmodule BasicTest do
  # https://elixirschool.com/en/lessons/basics/basics#basic-data-types-3
  use ExUnit.Case

  test "Basic Data Types" do
    assert 255    == 255
    assert 0b0110 == 6    # binary
    assert 0o644  == 420  # octal
    assert 0x1F   == 31   # hexadecimal
    assert 0x1f   == 31   # hexadecimal

    ## Float
    assert 3.14  == 3.140
    assert 10.0e-11 == 1.0e-10    # 10e-10 won't work


    ## Booleans
    assert true == true
    assert false == false

    ## Atoms
    assert is_atom(:foo)
    refute :foo == :bar
    assert is_atom(:true)             # duality of :true, true
    assert is_atom(true)
    assert :true === true

    assert is_atom(NotExistingModule) # module name is atom
    assert is_atom(BasicTest)
    assert __MODULE__ == BasicTest
    assert is_atom(:crypto)           # :crypto is an Erlang module

    ## Strings
    assert "Hello" == "Hello"
    assert "⍺" == "⍺"
    str = "foo
bar"
    assert str == "foo\nbar"
  end
  test "Basic Operations" do
    assert 2 + 2 == 4
  end
end
