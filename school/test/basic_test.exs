## Ignore warning, https://elixirforum.com/t/how-to-disable-redefining-warning/53342
# Code.put_compiler_option(:ignore_module_conflict, true)
## Fix font not displayed properly
# chcp 65001 # from https://groups.google.com/g/elixir-lang-talk/c/C6YrOKQ81PI
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
    ## Arithmetic
    assert 2 + 2 == 4
    assert 2 - 1 == 1
    assert 2 * 5 == 10
    assert is_float(10/5)        # / output a float
    assert 10 / 5 == 2;
    assert is_integer(div(10,5)) # div output integer
    assert div(10,5) == 2
    assert is_integer(rem(10,3)) # remainder is integer
    assert rem(10,3) == 1        # remainder

    ## Boolean
    assert -20   || true == -20  # -20 is true
    assert false || 42 == 42
    assert nil   || 13 == 13     # nil is false
    assert 0     || 19 == 19     # 0 is false
    assert !42 == false          # 42 is true

    ## and, or, not must operate on boolean
    assert true and 17 == 17
    # 17 and true raise BadBooleanError
    assert not false
    # not 17 raise ArgumentError

    ## Comparison
    refute 1 > 2
    assert 1 != 2
    assert 2 == 2
    assert 2 <= 3

    assert 2 == 2.0
    assert 2 !== 2.0
    # sort order of different types
    # number < atom < reference < function < port < pid < tuple < map < list < bitstring

    ## String Interpolation
    name = "Sean"
    assert "Hello #{name}" == "Hello Sean"

    ## String Concatenation
    assert "Hello " <> name == "Hello Sean"
  end
end
