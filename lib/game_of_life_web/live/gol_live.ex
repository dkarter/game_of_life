defmodule GameOfLifeWeb.GOLLive do
  @moduledoc """
  Presentation layer for Game of Life
  """

  use Phoenix.LiveView

  alias GameOfLife.Board

  @alive "❇️"
  @dead "⬜️"

  def render(assigns) do
    ~L"""
      <div class="settings-container">
        <form name="settings" phx-change="update_settings">
          <div class="slider-container">
            <div>Size</div>
            <input type="range" min="10" max="40" value=<%= @board.width %> class="slider" name="board_size" />
            <label><%= @board.width %></label>
          </div>
          <div class="slider-container">
            <div>Speed</div>
            <input type="range" min="1" max="1000" value=<%= @speed %> class="slider" name="speed" />
            <label><%= @speed %></label>
          </div>
          <button phx-click="reset">Reset</button>
        </form>
      </div>
      <div class="board-container">
        <div class="board">
          <%= for y <- 0..(@board.height - 1) do %>
            <div class="row">
              <%= for  x <- 0..(@board.width - 1) do %>
                <div class="cell"><%= display_cell(Board.cell_at(@board, {x, y})) %></div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    """
  end

  def mount(_session, socket) do
    speed = 1000
    Process.send_after(self(), :tick, speed)

    board = Board.random_board()

    socket =
      socket
      |> assign(:board, board)
      |> assign(:speed, speed)

    {:ok, socket}
  end

  def handle_info(:tick, socket) do
    %{assigns: %{speed: speed, board: board}} = socket
    board = Board.next_state(board)

    Process.send_after(self(), :tick, speed)

    {:noreply, assign(socket, :board, board)}
  end

  def handle_event("reset", _form_data, socket) do
    %{assigns: %{board: %{width: size}}} = socket
    new_board = Board.random_board(size)

    socket =
      socket
      |> assign(:board, new_board)

    {:noreply, socket}
  end

  def handle_event("update_settings", form_data, socket) do
    %{"board_size" => size, "speed" => speed} = form_data
    %{assigns: %{board: %{width: width} = board}} = socket
    size = String.to_integer(size)

    board =
      if width != size do
        Board.random_board(size)
      else
        board
      end

    socket =
      socket
      |> assign(:board, board)
      |> assign(:speed, String.to_integer(speed))

    {:noreply, socket}
  end

  defp display_cell(1), do: @alive
  defp display_cell(0), do: @dead
end
