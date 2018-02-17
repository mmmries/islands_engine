defmodule RulesTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.Rules

  test "unexpected events return an error" do
    assert Rules.new() |> Rules.check(:wat) == :error
  end

  test "adding a second player to a game" do
    assert {:ok, %{state: :players_set}} =  Rules.new() |> Rules.check(:add_player)
  end

  test "a user can position their islands when they are not set" do
    rules = %Rules{state: :players_set, player1: :islands_not_set}
    assert {:ok, ^rules} = Rules.check(rules, {:position_islands, :player1})
  end

  test "a user cannot position their islands when they are set" do
    rules = %Rules{state: :players_set, player1: :islands_set}
    assert :error = Rules.check(rules, {:position_islands, :player1})
  end

  test "a user can (re)set their islands" do
    rules = %Rules{state: :players_set, player1: :islands_not_set}
    assert {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert %Rules{state: :players_set, player1: :islands_set} = rules

    rules = %Rules{state: :players_set, player1: :islands_set}
    assert {:ok, rules} = Rules.check(rules, {:set_islands, :player1})
    assert %Rules{state: :players_set, player1: :islands_set} = rules
  end

  test "the state transitions to player 1's turn when both players have set their islands" do
    rules = %Rules{state: :players_set, player1: :islands_set}
    assert {:ok, rules} = Rules.check(rules, {:set_islands, :player2})
    assert %Rules{state: :player1_turn} = rules
  end

  test "players cannot position or set their islands once they are taking turns" do
    rules = %Rules{state: :player1_turn}
    assert :error = Rules.check(rules, {:position_islands, :player2})
    assert :error = Rules.check(rules, {:set_islands, :player2})
  end

  test "player1 can guess during their own turn, but not player2 turns" do
    rules = %Rules{state: :player1_turn}
    assert {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player1})
    assert rules.state == :player2_turn

    rules = %Rules{state: :player1_turn}
    assert :error = Rules.check(rules, {:guess_coordinate, :player2})
  end

  test "player2 can guess during their own turn, but not player1 turns" do
    rules = %Rules{state: :player2_turn}
    assert {:ok, rules} = Rules.check(rules, {:guess_coordinate, :player2})
    assert rules.state == :player1_turn

    rules = %Rules{state: :player2_turn}
    assert :error = Rules.check(rules, {:guess_coordinate, :player1})
  end

  test "win checks do not advance the state when there is no win" do
    rules = %Rules{state: :player2_turn}
    assert {:ok, ^rules} = Rules.check(rules, {:win_check, :no_win})
  end

  test "win checks do advance the state when there is a win" do
    rules = %Rules{state: :player2_turn}
    assert {:ok, rules} = Rules.check(rules, {:win_check, :win})
    assert rules.state == :game_over
  end
end
