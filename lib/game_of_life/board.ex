defmodule GameOfLife.Board do
  @moduledoc """
  Manipulates the board data structure
  """

  defstruct cells: [],
            width: 10,
            height: 10

  def from_2d_cell_list(cell_list) do
    %__MODULE__{
      width: cell_list |> List.first() |> length(),
      height: cell_list |> length(),
      cells: Enum.concat(cell_list)
    }
  end

  def random_board(size \\ 10) do
    cells = random_cells(size, size)
    %__MODULE__{width: size, height: size, cells: cells}
  end

  def cell_at(%{width: w, height: h}, {x, y}) when x >= w or y >= h, do: nil
  def cell_at(_board, {x, y}) when x < 0 or y < 0, do: nil

  def cell_at(board, {x, y}) do
    index = to_flat_index(board, {x, y})
    board.cells |> Enum.at(index)
  end

  def cells_at(board, coordinates) do
    coordinates
    |> Enum.map(fn {x, y} -> cell_at(board, {x, y}) end)
  end

  def live_neighbor_count(board, {x, y}) do
    board
    |> cells_at(neighbor_coordinates({x, y}))
    |> Enum.count(fn cell -> cell == 1 end)
  end

  def neighbor_coordinates({x, y}) do
    [
      # top
      {x - 1, y - 1},
      {x, y - 1},
      {x + 1, y - 1},
      # sides
      {x + 1, y},
      {x - 1, y},
      # bottom
      {x - 1, y + 1},
      {x, y + 1},
      {x + 1, y + 1}
    ]
  end

  def next_state(board) do
    cells =
      board
      |> coordinates()
      |> Enum.chunk_every(board.width)
      |> Enum.map(fn chunk ->
        Task.async(fn ->
          chunk
          |> Enum.map(&cell_next_state(board, &1))
        end)
      end)
      |> Enum.map(&Task.await/1)
      |> Enum.concat()

    Map.put(board, :cells, cells)
  end

  def update_cell(board, {x, y}, alive) do
    %{cells: cells} = board
    index = to_flat_index(board, {x, y})
    cells = List.update_at(cells, index, fn _ -> alive end)

    Map.put(board, :cells, cells)
  end

  def coordinates(board) do
    %{height: height, width: width} = board
    for y <- 0..(height - 1), x <- 0..(width - 1), do: {x, y}
  end

  def cell_next_state(board, {x, y}) do
    board
    |> cell_at({x, y})
    |> cell_next_state(live_neighbor_count(board, {x, y}))
  end

  def cell_next_state(1, count) when count < 2, do: 0
  def cell_next_state(1, count) when count in [2, 3], do: 1
  def cell_next_state(1, count) when count >= 4, do: 0
  def cell_next_state(0, count) when count < 3, do: 0
  def cell_next_state(0, count) when count == 3, do: 1
  def cell_next_state(0, count) when count > 3, do: 0

  defp random_cells(width, height) do
    1..(width * height)
    |> Enum.map(fn _ -> Enum.random([1, 0]) end)
  end

  defp to_flat_index(board, {x, y}), do: y * board.height + x
end
