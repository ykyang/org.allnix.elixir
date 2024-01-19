defmodule ModulesTest do
  # https://elixirschool.com/en/lessons/basics/modules

  # derive from Protocol, Inspect is a protocol
  # @derive {Inspect, only: [:name]}
  # @derive {Inspect, except: [:roles]}
  defstruct name: "Elle", roles: []

  use ExUnit.Case


  @greeting "Hello"

  def greeting(name) do
    ~s(#{@greeting} #{name}.)
  end

  test "Modules" do
    ## Module Attributes
    assert "Hello" = @greeting
    assert "Hello Elle." = greeting("Elle")
  end

  test "Structs" do
    ## assign
    user = %ModulesTest{}
    assert user.name == "Elle"

    user = %ModulesTest{name: "Anna"}
    assert user.name == "Anna"

    elle = %ModulesTest{name: "Elle", roles: [:manager]}
    assert elle.name == "Elle"
    assert elle.roles == [:manager]

    ## update
    anna = %{elle | name: "Anna"}
    assert anna.name == "Anna"
    assert anna.roles == [:manager]

    ## Match
    assert %{name: "Anna"} = anna

    ## @derive
    # see the beginning
  end

  test "Composition" do
    ## Use the last name of a module
    # alias Sayings.Greetings
    # Greetings.greeting()

    ## Assign a new name
    # alias Saying.Greetings, as: Hi
    # Hi.greeting()

    ## Alias multiple at once
    # alias Sayings.{Greetings, Farewells}

    ## Import function
    # import List

    ## Filtering
    # import List, only: [last: 1]
    # import List, except: [last: 1]
    # import List, only: :functions  # import functions only
    # import List, only: :macros     # import macros only

    ## require
    # Requires macro from another module
    # require SuperMacros

    ## use
    # Enable another module to modify our module
  end
end
