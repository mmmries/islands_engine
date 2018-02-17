defmodule GameTest do
  use ExUnit.Case, async: true
  alias IslandsEngine.{Coordinate,Game,Island}

  test "starting a game" do
    assert game = Game.start("Allie")
    assert game.player1.name == "Allie"
    assert game.rules.state == :initialized
  end

  test "joining a game" do
    assert {:ok, game} = Game.start("Allie") |> Game.join("Jim")
    assert game.player2.name == "Jim"
    assert game.rules.state == :players_set
  end

  test "a game cannot have 3 players, Bob" do
    assert {:ok, game} = Game.start("Allie") |> Game.join("Jim")
    assert :error = Game.join(game, "Bob")
  end

  test "users can position their ships" do
    assert {:ok, game} = Game.start("Allie") |> Game.join("Jim")
    assert {:ok, game} = Game.position_island(game, "Jim", :dot, Coordinate.new!(5,5))
    assert game.player2.board.dot == Island.new(:dot, Coordinate.new!(5,5)) |> elem(1)
  end

  test "users cannot position islands on top of each other" do
    assert {:ok, game} = Game.start("Allie") |> Game.join("Jim")
    assert {:ok, game} = Game.position_island(game, "Jim", :dot, Coordinate.new!(5,5))
    assert {:error, :overlapping_island} = Game.position_island(game, "Jim", :square, Coordinate.new!(5,5))
  end

  test "users can set their islands" do
    {:ok, game} = Game.start("Allie") |> Game.join("Jim")
    {:ok, game} = Game.position_island(game, "Allie", :dot, Coordinate.new!(2,1))
    {:ok, game} = Game.position_island(game, "Allie", :atoll, Coordinate.new!(1,1))
    {:ok, game} = Game.position_island(game, "Allie", :square, Coordinate.new!(4,1))
    {:ok, game} = Game.position_island(game, "Allie", :l_shape, Coordinate.new!(6,1))
    {:ok, game} = Game.position_island(game, "Allie", :s_shape, Coordinate.new!(1,3))
    assert {:ok, game} = Game.set_islands(game, "Allie")
    assert game.rules.player1 == :islands_set
  end

  test "users cannot set their islands if they are only partially positioned" do
    {:ok, game} = Game.start("Allie") |> Game.join("Jim")
    {:ok, game} = Game.position_island(game, "Allie", :dot, Coordinate.new!(2,1))
    {:ok, game} = Game.position_island(game, "Allie", :atoll, Coordinate.new!(1,1))
    assert {:error, :not_all_islands_positioned} = Game.set_islands(game, "Allie")
  end
end
