defmodule IslandsEngine.GameServer do
  use GenServer
  alias IslandsEngine.{Coordinate,Game}

  def start_link(player1_name) when is_binary(player1_name) do
    GenServer.start_link(__MODULE__, player1_name)
  end

  def join(server, name) when is_binary(name) do
    GenServer.call(server, {:join, name})
  end

  def position_island(server, name, type, %Coordinate{}=top_left) when is_binary(name) and is_atom(type) do
    GenServer.call(server, {:position_island, name, type, top_left})
  end

  def set_islands(server, name) when is_binary(name) do
    GenServer.call(server, {:set_islands, name})
  end

  def guess_coordinate(server, name, %Coordinate{}=coordinate) when is_binary(name) do
    GenServer.call(server, {:guess_coordinate, name, coordinate})
  end

  # Callbacks

  def init(player1_name) do
    {:ok, Game.start(player1_name)}
  end

  def handle_call({:join, name}, _from, game) do
    game |> Game.join(name) |> reply_response(game)
  end

  def handle_call({:position_island, name, type, top_left}, _from, game) do
    game |> Game.position_island(name, type, top_left) |> reply_response(game)
  end

  def handle_call({:set_islands, name}, _from, game) do
    game |> Game.set_islands(name) |> reply_response(game)
  end

  def handle_call({:guess_coordinate, name, coordinate}, _from, game) do
    game |> Game.guess_coordinate(name, coordinate) |> reply_response(game)
  end

  # Private Functions

  defp reply_response({:ok, game}, _), do: {:reply, :ok, game}
  defp reply_response({:ok, game, hit_or_miss, forested, win_or_not}, _), do: {:reply, {:ok, hit_or_miss, forested, win_or_not}, game}
  defp reply_response(:error, game), do: {:reply, :error, game}
  defp reply_response({:error, reason}, game), do: {:reply, {:error, reason}, game}
end
