defmodule IslandsEngine.Application do
  @moduledoc false

  use Application
  alias IslandsEngine.GameSupervisor

  def start(_type, _args) do
    :game_state = :ets.new(:game_state, [:public, :named_table])

    # List all child processes to be supervised
    children = [
      {Registry, keys: :unique, name: Registry.Game},
      GameSupervisor,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: IslandsEngine.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
