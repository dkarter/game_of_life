defmodule BoardBench do
  use Benchfella

  alias GameOfLife.Board

  @board Board.random_board(40)

  bench ".next_state sync" do
    Board.next_state(@board)
  end

  bench ".next_state async one process per row" do
    Board.next_state(@board, :async)
  end

  bench ".next_state async once process per cell" do
    Board.next_state(@board, :async_one_per_cell)
  end
end
