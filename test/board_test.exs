defmodule BoardTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Coordinate,Board,Island}

  test "positioning a valid island" do
    {:ok, island} = Island.new(:square, Coordinate.new(1, 1) |> elem(1))
    board = Board.new() |> Board.position_island(:square, island)
    assert Map.has_key?(board, :square)
  end

  test "re-positioning a valid island" do
    {:ok, island} = Island.new(:square, Coordinate.new(1, 1) |> elem(1))
    board = Board.new() |> Board.position_island(:square, island)
    {:ok, island} = Island.new(:square, Coordinate.new(5, 5) |> elem(1))
    board = Board.position_island(board, :square, island)
    assert Map.has_key?(board, :square)
    assert Map.size(board) == 1
  end

  test "prevents overlapping island positions" do
    {:ok, square} = Island.new(:square, Coordinate.new(1, 1) |> elem(1))
    {:ok, dot} = Island.new(:dot, Coordinate.new(1, 2) |> elem(1))
    board = Board.new |> Board.position_island(:square, square)
    assert {:error, :overlapping_island} = Board.position_island(board, :dot, dot)
  end
end
