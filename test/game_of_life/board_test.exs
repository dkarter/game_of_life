defmodule GameOfLife.BoardTest do
  use ExUnit.Case

  alias GameOfLife.Board

  describe ".from_2d_cell_list" do
    test "returns a one dimensional list of cells from 2d list of cells" do
      cells = [
        [1, 0, 1, 1, 0],
        [0, 1, 1, 1, 0],
        [1, 0, 1, 0, 0],
        [0, 1, 1, 0, 0],
        [0, 0, 1, 1, 1]
      ]

      flattened_cells = cells |> Enum.concat()
      assert %Board{width: 5, height: 5, cells: flattened_cells} == Board.from_2d_cell_list(cells)
    end
  end

  describe ".random_board" do
    test "creates a new board with default size" do
      assert board = %Board{width: 10, height: 10, cells: cells} = Board.random_board()
      assert length(cells) == 100
      refute board == Board.random_board()
    end
  end

  describe ".find_cell" do
    setup do
      board =
        [
          [0, 1, 2],
          [3, 4, 5],
          [6, 7, 8]
        ]
        |> Board.from_2d_cell_list()

      {:ok, %{board: board}}
    end

    test "returns the cell at the specified coordinates", %{board: board} do
      assert Board.find_cell(board, {0, 0}) == 0
      assert Board.find_cell(board, {1, 0}) == 1
      assert Board.find_cell(board, {2, 0}) == 2
      assert Board.find_cell(board, {0, 1}) == 3
      assert Board.find_cell(board, {1, 1}) == 4
      assert Board.find_cell(board, {2, 1}) == 5
      assert Board.find_cell(board, {0, 2}) == 6
      assert Board.find_cell(board, {1, 2}) == 7
      assert Board.find_cell(board, {2, 2}) == 8
    end

    test "returns nil when outside of range", %{board: board} do
      assert Board.find_cell(board, {0, 3}) == nil
      assert Board.find_cell(board, {3, 0}) == nil
      assert Board.find_cell(board, {-1, 2}) == nil
    end
  end

  describe ".live_neighbor_count" do
    test "returns correct live neighbor count" do
      board =
        [
          [1, 0, 1, 1, 0],
          [0, 1, 1, 1, 0],
          [1, 0, 1, 0, 0],
          [0, 1, 1, 0, 0],
          [0, 0, 1, 1, 1]
        ]
        |> Board.from_2d_cell_list()

      assert Board.live_neighbor_count(board, {0, 0}) == 1
      assert Board.live_neighbor_count(board, {1, 0}) == 4
      assert Board.live_neighbor_count(board, {2, 0}) == 4
      assert Board.live_neighbor_count(board, {4, 0}) == 2
      assert Board.live_neighbor_count(board, {2, 2}) == 5
    end
  end

  describe ".coordinates" do
    test "returns all coordinates for a board" do
      board =
        [
          [0, 0, 0],
          [0, 0, 0],
          [0, 0, 0]
        ]
        |> Board.from_2d_cell_list()

      coordinates =
        [
          [{0, 0}, {1, 0}, {2, 0}],
          [{0, 1}, {1, 1}, {2, 1}],
          [{0, 2}, {1, 2}, {2, 2}]
        ]
        |> Enum.concat()

      assert Board.coordinates(board) == coordinates
    end
  end

  describe ".update_cell" do
    test "sets the cell's alive/dead status" do
      board =
        [
          [0, 0, 0],
          [0, 0, 0],
          [0, 0, 0]
        ]
        |> Board.from_2d_cell_list()

      {x, y} = {1, 1}
      board = Board.update_cell(board, {x, y}, 1)
      assert Board.find_cell(board, {x, y}) == 1
    end
  end

  describe ".next_state" do
    test "rotating cell set" do
      initial_board =
        [
          [0, 1, 0],
          [0, 1, 0],
          [0, 1, 0]
        ]
        |> Board.from_2d_cell_list()

      rotated_board =
        [
          [0, 0, 0],
          [1, 1, 1],
          [0, 0, 0]
        ]
        |> Board.from_2d_cell_list()

      assert Board.next_state(initial_board) == rotated_board
      assert Board.next_state(rotated_board) == initial_board
    end
  end
end
