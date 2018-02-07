defmodule IslandsEngine.IslandTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Coordinate, Island}

  test "it can create the known islands" do
    {:ok, coordinate} = Coordinate.new(1, 1)
    assert {:ok, %Island{}} = Island.new(:square, coordinate)
    assert {:ok, %Island{}} = Island.new(:atoll, coordinate)
    assert {:ok, %Island{}} = Island.new(:dot, coordinate)
    assert {:ok, %Island{}} = Island.new(:l_shape, coordinate)
    assert {:ok, %Island{}} = Island.new(:s_shape, coordinate)
  end

  test "it returns an error if you give it an invalid type" do
    {:ok, coordinate} = Coordinate.new(1, 1)
    assert {:error, :invalid_shape} = Island.new(:hula, coordinate)
  end

  test "it returns an error if the island runs off the board" do
    {:ok, coordinate} = Coordinate.new(10, 10)
    assert {:error, :invalid_coordinate} = Island.new(:square, coordinate)
  end
end
