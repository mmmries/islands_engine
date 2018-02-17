defmodule IslandsEngine.Rules do
  alias __MODULE__
  defstruct state: :initialized,
            player1: :islands_not_set,
            player2: :islands_not_set

  def new, do: %Rules{}

  def check(%Rules{state: :initialized} = rules, :add_player) do
    {:ok, %Rules{rules | state: :players_set}}
  end
  def check(%Rules{state: :players_set} = rules, {:position_islands, player}) do
    case Map.fetch!(rules, player) do
      :islands_set -> :error
      :islands_not_set -> {:ok, rules}
    end
  end
  def check(%Rules{state: :players_set} = rules, {:set_islands, player}) do
    case Map.put(rules, player, :islands_set) do
      %Rules{player1: :islands_set, player2: :islands_set} = rules ->
        {:ok, %Rules{rules | state: :player1_turn}}
      rules ->
        {:ok, rules}
    end
  end
  def check(%Rules{state: :player1_turn} = rules, {:guess_coordinate, :player1}) do
    {:ok, %Rules{rules | state: :player2_turn}}
  end
  def check(%Rules{state: :player1_turn}, {:guess_coordinate, :player2}) do
    :error
  end
  def check(%Rules{state: :player2_turn} = rules, {:guess_coordinate, :player2}) do
    {:ok, %Rules{rules | state: :player1_turn}}
  end
  def check(%Rules{state: :player2_turn}, {:guess_coordinate, :player1}) do
    :error
  end
  def check(%Rules{state: state} = rules, {:win_check, :no_win})
    when state in [:player1_turn, :player2_turn] do
    {:ok, rules}
  end
  def check(%Rules{state: state} = rules, {:win_check, :win})
    when state in [:player1_turn, :player2_turn] do
    {:ok, %Rules{rules | state: :game_over}}
  end
  def check(_, _), do: :error
end
