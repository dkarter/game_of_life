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
      assert %Board{width: 10, height: 10, cells: cells} = Board.random_board()
      assert length(cells) == 100
    end
  end

  describe ".cell_at" do
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
      assert Board.cell_at(board, {0, 0}) == 0
      assert Board.cell_at(board, {1, 0}) == 1
      assert Board.cell_at(board, {2, 0}) == 2
      assert Board.cell_at(board, {0, 1}) == 3
      assert Board.cell_at(board, {1, 1}) == 4
      assert Board.cell_at(board, {2, 1}) == 5
      assert Board.cell_at(board, {0, 2}) == 6
      assert Board.cell_at(board, {1, 2}) == 7
      assert Board.cell_at(board, {2, 2}) == 8
    end

    test "returns nil when outside of range", %{board: board} do
      assert Board.cell_at(board, {0, 3}) == nil
      assert Board.cell_at(board, {3, 0}) == nil
      assert Board.cell_at(board, {-1, 2}) == nil
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

  describe ".cell_next_state" do
    test "live cell with one or no neighbors dies, as if by solitude" do
      assert Board.cell_next_state(1, 0) == 0
      assert Board.cell_next_state(1, 1) == 0
    end

    test "live cell with two or three neighbors survives" do
      assert Board.cell_next_state(1, 2) == 1
      assert Board.cell_next_state(1, 3) == 1
    end

    test "live cell with four or more neighbors dies, as if by overpopulation" do
      4..8
      |> Enum.each(fn count ->
        assert Board.cell_next_state(1, count) == 0
      end)
    end

    test "dead cell with exactly three neighbors becomes alive" do
      assert Board.cell_next_state(0, 3) == 1
    end

    test "dead cell with less more than three neighbors remains dead" do
      0..2
      |> Enum.each(fn count ->
        assert Board.cell_next_state(0, count) == 0
      end)
    end

    test "dead cell with more than three neighbors remains dead" do
      4..8
      |> Enum.each(fn count ->
        assert Board.cell_next_state(0, count) == 0
      end)
    end

    test "integration test" do
      board =
        [
          [1, 0, 1, 1, 0, 1],
          [0, 1, 1, 0, 0, 0],
          [1, 0, 1, 0, 1, 0],
          [0, 0, 1, 0, 0, 0],
          [0, 0, 1, 1, 1, 1],
          [0, 0, 1, 1, 1, 1]
        ]
        |> Board.from_2d_cell_list()

      assert Board.cell_next_state(board, {0, 0}) == 0
      assert Board.cell_next_state(board, {0, 1}) == 1
      assert Board.cell_next_state(board, {0, 3}) == 0
      assert Board.cell_next_state(board, {2, 0}) == 1
      assert Board.cell_next_state(board, {2, 4}) == 0
      assert Board.cell_next_state(board, {4, 2}) == 0
      assert Board.cell_next_state(board, {5, 4}) == 1
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
      assert Board.cell_at(board, {x, y}) == 1
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
