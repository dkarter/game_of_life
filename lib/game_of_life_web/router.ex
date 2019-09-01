defmodule GameOfLifeWeb.Router do
  use GameOfLifeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
  end

  scope "/", GameOfLifeWeb do
    pipe_through :browser

    live "/", GOLLive
  end
end
