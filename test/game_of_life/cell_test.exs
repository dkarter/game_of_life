defmodule GameOfLife.CellTest do
  use ExUnit.Case

  alias GameOfLife.Cell

  describe ".next_state" do
    test "live cell with one or no neighbors dies, as if by solitude" do
      assert Cell.next_state(1, 0) == 0
      assert Cell.next_state(1, 1) == 0
    end

    test "live cell with two or three neighbors survives" do
      assert Cell.next_state(1, 2) == 1
      assert Cell.next_state(1, 3) == 1
    end

    test "live cell with four or more neighbors dies, as if by overpopulation" do
      4..8
      |> Enum.each(fn count ->
        assert Cell.next_state(1, count) == 0
      end)
    end

    test "dead cell with exactly three neighbors becomes alive" do
      assert Cell.next_state(0, 3) == 1
    end

    test "dead cell with less more than three neighbors remains dead" do
      0..2
      |> Enum.each(fn count ->
        assert Cell.next_state(0, count) == 0
      end)
    end

    test "dead cell with more than three neighbors remains dead" do
      4..8
      |> Enum.each(fn count ->
        assert Cell.next_state(0, count) == 0
      end)
    end
  end
end
