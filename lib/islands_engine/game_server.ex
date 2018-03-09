defmodule IslandsEngine.GameServer do
  use GenServer, restart: :transient
  alias IslandsEngine.{Coordinate,Game}
  require Logger
  @timeout 60_000

  def start_link(player1_name) when is_binary(player1_name) do
    GenServer.start_link(__MODULE__, player1_name, name: via_tuple(player1_name))
  end

  def join(server, name) when is_binary(name) do
    call(server, {:join, name})
  end

  def position_island(server, name, type, %Coordinate{}=top_left) when is_binary(name) and is_atom(type) do
    call(server, {:position_island, name, type, top_left})
  end

  def set_islands(server, name) when is_binary(name) do
    call(server, {:set_islands, name})
  end

  def guess_coordinate(server, name, %Coordinate{}=coordinate) when is_binary(name) do
    call(server, {:guess_coordinate, name, coordinate})
  end

  def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}

  defp call(game_name, message) when is_binary(game_name) do
    call(via_tuple(game_name), message)
  end
  defp call(server, message) do
    GenServer.call(server, message)
  end

  # Callbacks

  def init(player1_name) do
    {:ok, Game.start(player1_name), @timeout}
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

  def handle_info(:timeout, state) do
    {:stop, {:shutdown, :timeout}, state}
  end
  def handle_info(other, state) do
    Logger.error("#{__MODULE__} received unexpected message in handle_info #{inspect(other)}")
    {:ok, state, @timeout}
  end

  # Private Functions

  defp reply_response({:ok, game}, _), do: {:reply, :ok, game, @timeout}
  defp reply_response({:ok, game, hit_or_miss, forested, win_or_not}, _), do: {:reply, {:ok, hit_or_miss, forested, win_or_not}, game, @timeout}
  defp reply_response(:error, game), do: {:reply, :error, game, @timeout}
  defp reply_response({:error, reason}, game), do: {:reply, {:error, reason}, game, @timeout}
end
