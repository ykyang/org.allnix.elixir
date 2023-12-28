# c "lib/learn.exs"
# r TestNum

## Branching with multi-clause functions
defmodule Learn do
  import ExUnit.Assertions

  def test(x) when x < 0, do: :negative
  def test(0), do: :zero
  def test(x), do: :positive

  def double(x) when is_number(x), do: 2*x
  def double(x) when is_binary(x), do: x <> x

  def run_1() do
    assert TestNum.test(-1) == :negative
    assert TestNum.test(1) == :positive

    assert double(2) == 4
    assert double("Jar") == "JarJar"
    true
  end

  def print(1), do: IO.puts(1)
  def print(n) do
    print(n-1)
    IO.puts(n)
  end

  # def sum([]), do: 0
  # def sum([head | tail]) do
  #   head + sum(tail)
  # end

  def sum(list) do
    do_sum(0, list)
  end
  def do_sum(current_sum, []) do # stop function
    current_sum
  end
  def do_sum(current_sum, [head | tail]) do
    do_sum(current_sum+head, tail)
  end
  ## Sum list of mixed types
  defp add_num(num, sum) when is_number(num), do: num+sum
  defp add_num(_, sum), do: sum
  def sum_num(enumerable) do
    Enum.reduce(enumerable, 0, &add_num/2)
  end

  def run_2() do
    print(5)
    assert sum([1,2,3,4]) == Enum.sum([1,2,3,4])
    assert Enum.map([1,2,3], fn x->2*x end) == [2,4,6]
    assert Enum.filter([1,2,3], fn x->rem(x,2) == 1 end) == [1,3]
    assert Enum.reduce([1,2,3], 0, fn e,sum -> e + sum end) == 6
    # Capture syntax
    assert Enum.reduce([1,2,3], 0, &(&1+&2)) == 6
    assert Enum.reduce([1,2,3], 0, &+/2) == 6

    ## Sum list of mixed types
    assert sum_num([1, "string", 2, :x, 3]) == 6

    ## Comprehensions
    out = for x <- [1,2,3] do x*x end
    assert out == [1,4,9]
    out = for x <- [1,2], y <- [1,2], do: {x,y,x*y}
    assert out == [{1,1,1}, {1,2,2}, {2,1,2},{2,2,4}]

    multiplication_table = for x <- 1..9, y <- 1..9, into: %{} do
      {{x,y}, x*y}
    end
    assert multiplication_table[{2,3}] == 6

    ### filter
    multiplication_table =
      for x <- 1..9, y <- 1..9, x <= y, into: %{} do
        {{x,y}, x*y}
      end

    assert multiplication_table[{2,3}] == 6
    assert multiplication_table[{3,2}] == nil

    true
  end

  def large_lines!(path) do
    File.stream!(path)
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.filter(&String.length(&1) > 80)
  end
  def run_3() do
    ## 3.4.5 Streams
    employees = ["Alice", "Bob", "John"]
    out = employees
           |> Enum.with_index() # {"Alice", 0} ...
           |> Enum.map(fn {e,i} -> {i+1,e} end)

    #Enum.each(out, fn x -> IO.puts("#{elem(x,0)}. #{elem(x,1)}") end)
    Enum.each(out, fn {i,e} -> IO.puts("#{i}. #{e}") end)

    out = Stream.map([1,2,3], fn x -> 2*x end)
    # out = Enum.to_list(out)
    # out = Enum.take(out, 1)
    # out

    [9, -1, "foo", 25, 49]
    |> Stream.filter(fn x -> is_number(x) && x > 0 end)
    |> Stream.map(fn x -> {x, :math.sqrt(x)} end)
    |> Stream.with_index(1)
    |> Enum.each(fn {{x,x2},i} -> IO.puts("#{i}. sqrt(#{x}) = #{x2}") end)
    #|> Enum.each(fn {x,x2} -> IO.puts("#{x} #{x2}") end)
    #############################################################################

    out = large_lines!("lib/learn.exs")

    natural_numbers = Stream.iterate(1, fn n -> n+1 end)
    assert Enum.take(natural_numbers, 3) == [1,2,3]

    true
  end




  ## 3.4.3 Higher-order functions


end



# TestNum.test(-1)
# TestNum.test(1)
