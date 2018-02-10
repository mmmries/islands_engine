defmodule IslandsEngine.Board do
  alias IslandsEngine.{Coordinate, Island}

  def new(), do: %{}

  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_islands_for_hit(coordinate)
    |> guess_response(board)
  end

  def all_islands_positioned?(board) do
    Island.types() -- Map.keys(board) == []
  end

  def position_island(board, key, %Island{}=island) do
    case overlaps_existing_island?(board, key, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  defp all_islands_forested?(board) do
    Enum.all?(board, fn({_key, island}) ->
      Island.forested?(island)
    end)
  end

  defp check_islands_for_hit(board, coordinate) do
    Enum.reduce(board, :miss, fn({key, island}, acc) ->
      case Island.guess(island, coordinate) do
        :miss -> acc
        {:hit, updated_island} -> {:hit, key, updated_island}
      end
    end)
  end

  defp guess_response(:miss, board), do: {:miss, :none, :no_win, board}
  defp guess_response({:hit, key, island}, board) do
    board = Map.put(board, key, island)
    win_or_no = case all_islands_forested?(board) do
      true -> :win
      false -> :no_win
    end
    forested_key = case Island.forested?(island) do
      true -> key
      false -> :none
    end
    {:hit, forested_key, win_or_no, board}
  end

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      new_key != key and Island.overlaps?(island, new_island)
    end)
  end
end
