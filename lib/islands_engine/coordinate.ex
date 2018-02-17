defmodule IslandsEngine.Coordinate do
  alias __MODULE__
  @enforce_keys [:row, :col]
  defstruct [:row, :col]

  @board_range 1..10

  def new(row, col) when row in @board_range and col in @board_range do
    {:ok, %Coordinate{row: row, col: col}}
  end

  def new(_, _), do: {:error, :invalid_coordinate}

  def new!(row, col) do
    case new(row, col) do
      {:ok, coordinate} -> coordinate
      {:error, detail} -> raise "Cannot create coordinate #{inspect detail}"
    end
  end
end
