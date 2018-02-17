defmodule IslandsEngine.Game do
  alias IslandsEngine.{Board,Game,Guesses,Island,Rules}
  defstruct player1: %{},
            player2: %{},
            rules: nil

  def start(player1_name) when is_binary(player1_name) do
    %Game{
      player1: %{name: player1_name, board: Board.new(), guesses: Guesses.new()},
      player2: %{name: nil, board: Board.new(), guesses: Guesses.new()},
      rules: Rules.new(),
    }
  end

  def join(%Game{}=game, player2_name) when is_binary(player2_name) do
    with {:ok, rules} <- Rules.check(game.rules, :add_player),
         player2 <- Map.put(game.player2, :name, player2_name),
         do: {:ok, %Game{game | rules: rules, player2: player2}}
  end

  def position_island(%Game{}=game, player, type, coordinate) do
    with {:ok, key} <- lookup_player_key(game, player),
         {:ok, rules} <- Rules.check(game.rules, {:position_islands, key}),
         player <- Map.get(game, key),
         {:ok, island} <- Island.new(type, coordinate),
         board=%{} <- Board.position_island(player.board, type, island),
         game <- Map.put(game, key, %{player | board: board}),
         do: {:ok, %Game{game | rules: rules}}
  end

  def set_islands(%Game{}=game, player) do
    with {:ok, key} <- lookup_player_key(game, player),
         {:ok, rules} <- Rules.check(game.rules, {:set_islands, key}),
         board <- game |> Map.get(key) |> Map.get(:board),
         :ok <- all_islands_positioned?(board),
         do: {:ok, %Game{game | rules: rules}}
  end

  defp all_islands_positioned?(board) do
    case Board.all_islands_positioned?(board) do
      true -> :ok
      false -> {:error, :not_all_islands_positioned}
    end
  end

  defp lookup_player_key(%Game{player1: %{name: name}}, name), do: {:ok, :player1}
  defp lookup_player_key(%Game{player2: %{name: name}}, name), do: {:ok, :player2}
  defp lookup_player_key(_game, _name), do: :error
end
