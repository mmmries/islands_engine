defmodule IslandsEngine.CoordinateTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.Coordinate

  test "coordinates can be created that fall within the board" do
    assert Coordinate.new(1, 1) == {:ok, %Coordinate{col: 1, row: 1}}
  end

  test "coordinates cannot be created off the board" do
    assert Coordinate.new(0, 1) == {:error, :invalid_coordinate}
    assert Coordinate.new(1, 11) == {:error, :invalid_coordinate}
  end
end
