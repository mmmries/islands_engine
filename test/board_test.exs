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

  test "it knows when all islands have been positioned" do
    {:ok, atoll} = Island.new(:atoll, Coordinate.new(1, 1) |> elem(1))
    {:ok, dot} = Island.new(:dot, Coordinate.new(2, 1) |> elem(1))
    {:ok, l_shape} = Island.new(:square, Coordinate.new(5, 5) |> elem(1))
    {:ok, s_shape} = Island.new(:dot, Coordinate.new(1, 3) |> elem(1))
    {:ok, square} = Island.new(:square, Coordinate.new(8, 8) |> elem(1))
    board = Board.new()
    assert Board.all_islands_positioned?(board) == false
    board = board |> Board.position_island(:atoll, atoll)
    assert Board.all_islands_positioned?(board) == false
    board = board |> Board.position_island(:dot, dot)
    assert Board.all_islands_positioned?(board) == false
    board = board |> Board.position_island(:l_shape, l_shape)
    assert Board.all_islands_positioned?(board) == false
    board = board |> Board.position_island(:s_shape, s_shape)
    assert Board.all_islands_positioned?(board) == false
    board = board |> Board.position_island(:square, square)
    assert Board.all_islands_positioned?(board) == true
  end

  test "letting a user guess" do
    {:ok, atoll} = Island.new(:atoll, Coordinate.new(1, 1) |> elem(1))
    {:ok, dot} = Island.new(:dot, Coordinate.new(2, 1) |> elem(1))
    {:ok, l_shape} = Island.new(:square, Coordinate.new(5, 5) |> elem(1))
    {:ok, s_shape} = Island.new(:dot, Coordinate.new(1, 3) |> elem(1))
    {:ok, square} = Island.new(:square, Coordinate.new(8, 8) |> elem(1))
    board = Board.new()
            |> Board.position_island(:atoll, atoll)
            |> Board.position_island(:dot, dot)
            |> Board.position_island(:l_shape, l_shape)
            |> Board.position_island(:s_shape, s_shape)
            |> Board.position_island(:square, square)
    assert {:miss, :none, :no_win, ^board} = Board.guess(board, Coordinate.new(6, 1) |> elem(1))
    assert {:hit, :dot, :no_win, board} = Board.guess(board, Coordinate.new(2,1) |> elem(1))
    assert {:hit, :none, :no_win, _board} = Board.guess(board, Coordinate.new(1,1) |> elem(1))
  end
end
