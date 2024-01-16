defmodule CollectionTest do
  use ExUnit.Case
  test "Lists" do
    list = [3.14, :pie, "Apple"] # linked list

    # faster to prepend
    assert ["π" | list] == ["π", 3.14, :pie, "Apple"]
    # slower to append
    assert list ++ ["Cherry"] == [3.14, :pie, "Apple", "Cherry"]

    ## List Concatenation
    assert [1,2]++[3,4] == [1,2,3,4]

    ## List Subtraction
    assert ["foo", :bar, 42]--[42, :bar] == ["foo"]
    assert ["foo", :bar, 42]--[42, 17]   == ["foo", :bar] # sub missing value
    assert [1,2,2,3,2,3]--[1,2,3,2] == [2,3] # sub duplicated value
    assert [2]--[2.0] == [2]  # strick comparison
    assert [2.0]--[2.0] == []

    ## Head/Tail
    assert hd([3.14, :pie, "Apple"]) == 3.14
    assert tl([3.14, :pie, "Apple"]) == [:pie, "Apple"]
    [head | tail] = [3.14, :pie, "Apple"] # pattern match
    assert head == 3.14
    assert tail == [:pie, "Apple"]
  end

  test "Tuples" do # not enumerable
    # stored contiguously
    {pi, pie, apple} = {3.14, :pie, "Apple"} # pattern matching
    assert pi == 3.14
    assert pie == :pie
    assert apple == "Apple"

    assert {_pi, :pie, _apple} = {3.14, :pie, "Apple"} # _ indicate unused variable
    # will fail {_pi, :pie, _apple} = {3.14, :cake, "Apple"} # _ indicate unused variable
  end

  test "Keyword lists" do
    # Keys are atoms
    # Keys are ordered
    # Keys do not have to be unique
    # commonly used to pass options to functions
    # list = [foo: "bar", hello: "world"]
    assert [foo: "bar", hello: "world"] != [hello: "world", foo: "bar"]
    assert [foo: "bar", hello: "world"] == [{:foo, "bar"}, {:hello, "world"}]
  end

  test "Maps" do
    # %{}
    db = %{:foo => "bar", "hello" => :world}
    assert db[:foo]    == "bar"
    assert db["hello"] == :world

    # duplicate
    db = %{:foo => "bar"}
    db = Map.put(db, :foo, :world)
    assert db[:foo] == :world

    # special syntax when keys are atom
    assert %{foo: "bar", hello: :world} ==  %{:foo => "bar", :hello => :world}

    # Update existing key
    db = %{foo: "bar", hello: "world"}
    assert db[:foo] == "bar"
    db = %{db | foo: "zzz"}  # Update
    assert db[:foo] == "zzz"

    # Patter match
    %{foo: x, hello: "world"} = %{foo: "bar", hello: "world"}
    assert x == "bar"
  end
end
