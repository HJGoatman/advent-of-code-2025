defmodule AOC2025.Day07.TachyonManifoldCell do
  @enforce_keys [:value]
  defstruct [:value]

  def parse(input) do
    value =
      case input do
        "S" -> :start
        "." -> :empty
        "^" -> :splitter
      end

    %AOC2025.Day07.TachyonManifoldCell{value: value}
  end

  defimpl String.Chars do
    def to_string(%AOC2025.Day07.TachyonManifoldCell{value: value}) do
      case value do
        :start -> "S"
        :empty -> "."
        :splitter -> "^"
      end
    end
  end
end

defmodule AOC2025.Day07 do
  require Logger
  alias AOC2025.Day07.TachyonManifoldCell
  alias AOC2025.Utils.Grid

  @behaviour AOCDay

  @impl AOCDay
  def part_1(input) do
    {:ok, grid} = Grid.parse_grid(TachyonManifoldCell, input)
    Logger.debug("#{grid}")

    start_position =
      Grid.find_position(grid, fn value -> value == %TachyonManifoldCell{value: :start} end)

    Logger.debug("start_position: #{inspect(start_position)}")

    activated_splitters = simulate_beam_splitting(grid, start_position)

    num_splits =
      activated_splitters
      |> Stream.filter(fn splitter_pos -> splitter_pos != nil end)
      |> Enum.count()

    Integer.to_string(num_splits)
  end

  @impl AOCDay
  def part_2(input) do
  end

  def simulate_beam_splitting(grid, {x, y} = beam_position, visited \\ MapSet.new()) do
    if MapSet.member?(visited, beam_position) do
      MapSet.new([nil])
    else
      case Grid.get(grid, x, y) do
        nil ->
          MapSet.new([nil])

        %TachyonManifoldCell{value: :splitter} ->
          visited = MapSet.put(visited, {x, y})
          left_side = simulate_beam_splitting(grid, {x - 1, y}, visited)
          visited = MapSet.union(visited, left_side)
          right_side = simulate_beam_splitting(grid, {x + 1, y}, visited)
          MapSet.union(visited, right_side)

        %TachyonManifoldCell{value: v} when v in [:start, :empty] ->
          simulate_beam_splitting(grid, {x, y + 1}, visited)
      end
    end
  end
end
