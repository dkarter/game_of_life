defmodule GameOfLife.Board do
  @moduledoc """
  Manipulates the board data structure
  """

  defstruct cells: [],
            width: 10,
            height: 10

  @type coordinate :: {integer(), integer()}
  @type cell_state :: 1 | 0
  @type cell_list :: list(cell_state)

  @type t :: %GameOfLife.Board{
          cells: cell_list,
          height: integer(),
          width: integer()
        }

  @spec from_2d_cell_list(cell_list) :: t
  def from_2d_cell_list(cell_list) do
    %__MODULE__{
      width: cell_list |> List.first() |> length(),
      height: cell_list |> length(),
      cells: Enum.concat(cell_list)
    }
  end

  @spec random_board(integer()) :: t
  def random_board(size \\ 10) do
    cells = random_cells(size, size)
    %__MODULE__{width: size, height: size, cells: cells}
  end

  @spec cell_at(t, coordinate) :: cell_state | nil
  def cell_at(%{width: w, height: h}, {x, y}) when x >= w or y >= h, do: nil
  def cell_at(_board, {x, y}) when x < 0 or y < 0, do: nil

  def cell_at(board, {x, y}) do
    index = to_flat_index(board, {x, y})
    board.cells |> Enum.at(index)
  end

  @spec cells_at(t, list(coordinate)) :: list(cell_state | nil)
  def cells_at(board, coordinates) do
    coordinates
    |> Enum.map(fn {x, y} -> cell_at(board, {x, y}) end)
  end

  @spec live_neighbor_count(t, coordinate) :: integer()
  def live_neighbor_count(board, {x, y}) do
    board
    |> cells_at(neighbor_coordinates({x, y}))
    |> Enum.count(fn cell -> cell == 1 end)
  end

  @spec next_state(t) :: t
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

  @spec update_cell(t, coordinate, cell_state) :: t
  def update_cell(board, {x, y}, alive) do
    %{cells: cells} = board
    index = to_flat_index(board, {x, y})
    cells = List.update_at(cells, index, fn _ -> alive end)

    Map.put(board, :cells, cells)
  end

  @spec cell_next_state(t, coordinate) :: cell_state
  def cell_next_state(board, {x, y}) do
    board
    |> cell_at({x, y})
    |> compute_next_state(live_neighbor_count(board, {x, y}))
  end

  @spec coordinates(t) :: list(coordinate)
  def coordinates(board) do
    %{height: height, width: width} = board
    for y <- 0..(height - 1), x <- 0..(width - 1), do: {x, y}
  end

  @spec compute_next_state(cell_state, integer()) :: cell_state
  def compute_next_state(1, neighbor_count) when neighbor_count < 2, do: 0
  def compute_next_state(1, neighbor_count) when neighbor_count in [2, 3], do: 1
  def compute_next_state(1, neighbor_count) when neighbor_count >= 4, do: 0
  def compute_next_state(0, neighbor_count) when neighbor_count < 3, do: 0
  def compute_next_state(0, neighbor_count) when neighbor_count == 3, do: 1
  def compute_next_state(0, neighbor_count) when neighbor_count > 3, do: 0

  defp neighbor_coordinates({x, y}) do
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

  defp random_cells(width, height) do
    1..(width * height)
    |> Enum.map(fn _ -> Enum.random([1, 0]) end)
  end

  defp to_flat_index(board, {x, y}), do: y * board.height + x
end
