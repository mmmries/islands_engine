defmodule GuessesTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Coordinate,Guesses}

  test "adding a hit" do
    {:ok, coordinate} = Coordinate.new(1,1)
    guesses = Guesses.new() |> Guesses.add(:hit, coordinate)
    assert MapSet.size(guesses.hits) == 1
    assert MapSet.size(guesses.misses) == 0
  end

  test "adding a miss" do
    {:ok, coordinate} = Coordinate.new(1,1)
    guesses = Guesses.new() |> Guesses.add(:miss, coordinate)
    assert MapSet.size(guesses.hits) == 0
    assert MapSet.size(guesses.misses) == 1
  end
end
