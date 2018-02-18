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

  def make_guess(game, player, coordinate) do
    with {:ok, key} <- lookup_player_key(game, player),
         {:ok, rules} <- Rules.check(game.rules, {:guess_coordinate, key}),
         game <- %Game{game | rules: rules},
         do: guess(game, key, coordinate)
  end

  defp all_islands_positioned?(board) do
    case Board.all_islands_positioned?(board) do
      true -> :ok
      false -> {:error, :not_all_islands_positioned}
    end
  end

  defp guess(game, :player1, coordinate) do
    player = Map.fetch!(game, :player1)
    opponent = Map.fetch!(game, :player2)
    {hit_or_miss, forested, win_or_not, board} = Board.guess(opponent.board, coordinate)
    guesses = Guesses.add(player.guesses, hit_or_miss, coordinate)
    {:ok, rules} = Rules.check(game.rules, {:win_check, win_or_not})
    game = %Game{game | player1: %{player | guesses: guesses},
                        player2: %{opponent | board: board},
                        rules: rules}
    {:ok, game, hit_or_miss, forested, win_or_not}
  end
  defp guess(game, :player2, coordinate) do
    player = Map.fetch!(game, :player2)
    opponent = Map.fetch!(game, :player1)
    {hit_or_miss, forested, win_or_not, board} = Board.guess(opponent.board, coordinate)
    guesses = Guesses.add(player.guesses, hit_or_miss, coordinate)
    {:ok, rules} = Rules.check(game.rules, {:win_check, win_or_not})
    game = %Game{game | player2: %{player | guesses: guesses},
                        player1: %{opponent | board: board},
                        rules: rules}
    {:ok, game, hit_or_miss, forested, win_or_not}
  end

  defp lookup_player_key(%Game{player1: %{name: name}}, name), do: {:ok, :player1}
  defp lookup_player_key(%Game{player2: %{name: name}}, name), do: {:ok, :player2}
  defp lookup_player_key(_game, _name), do: :error
end
