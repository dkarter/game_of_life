defmodule GameOfLife.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [GameOfLifeWeb.Endpoint]

    opts = [
      name: GameOfLife.Supervisor,
      strategy: :one_for_one
    ]

    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    GameOfLifeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
