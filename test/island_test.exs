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

  test "it can tell if there is overlap between two islands" do
    {:ok, i1} = Island.new(:square, Coordinate.new(1, 1) |> elem(1))
    {:ok, i2} = Island.new(:square, Coordinate.new(2, 2) |> elem(1))
    {:ok, i3} = Island.new(:square, Coordinate.new(3, 3) |> elem(1))
    assert Island.overlaps?(i1, i2) == true
    assert Island.overlaps?(i2, i3) == true
    assert Island.overlaps?(i1, i3) == false
  end

  test "it accepts guesses" do
    {:ok, square} = Island.new(:square, Coordinate.new(1, 1) |> elem(1))
    assert MapSet.size(square.hit_coordinates) == 0
    assert {:hit, square} = Island.guess(square, Coordinate.new(1, 2) |> elem(1))
    assert MapSet.size(square.hit_coordinates) == 1
    assert :miss = Island.guess(square, Coordinate.new(3, 3) |> elem(1))
  end

  test "it knows when it's been forested" do
    {:ok, square} = Island.new(:square, Coordinate.new(1, 1) |> elem(1))
    assert Island.forested?(square) == false
    {:hit, square} = Island.guess(square, Coordinate.new(1, 1) |> elem(1))
    assert Island.forested?(square) == false
    {:hit, square} = Island.guess(square, Coordinate.new(1, 2) |> elem(1))
    assert Island.forested?(square) == false
    {:hit, square} = Island.guess(square, Coordinate.new(2, 1) |> elem(1))
    assert Island.forested?(square) == false
    {:hit, square} = Island.guess(square, Coordinate.new(2, 2) |> elem(1))
    assert Island.forested?(square) == true
  end
end
