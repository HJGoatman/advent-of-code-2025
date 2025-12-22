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

    {_, activated_splitters} = simulate_beam_splitting(grid, start_position)

    num_splits =
      activated_splitters
      |> Stream.filter(fn splitter_pos -> splitter_pos != nil end)
      |> Enum.count()

    Integer.to_string(num_splits)
  end

  @impl AOCDay
  def part_2(input) do
    {:ok, grid} = Grid.parse_grid(TachyonManifoldCell, input)
    Logger.debug("#{grid}")

    start_position =
      Grid.find_position(grid, fn value -> value == %TachyonManifoldCell{value: :start} end)

    {num_paths, _visited} = simulate_beam_splitting(grid, start_position)
    Integer.to_string(num_paths + 1)
  end

  defp simulate_beam_splitting(grid, {x, y} = beam_position, visited \\ Map.new()) do
    if Map.has_key?(visited, beam_position) do
      {Map.get(visited, beam_position), visited}
    else
      case Grid.get(grid, x, y) do
        nil ->
          {0, visited}

        %TachyonManifoldCell{value: :splitter} ->
          {left_side, left_vistied} = simulate_beam_splitting(grid, {x - 1, y}, visited)
          vistied = Map.merge(visited, left_vistied)
          {right_side, right_visited} = simulate_beam_splitting(grid, {x + 1, y}, vistied)
          visited = Map.merge(visited, right_visited)
          visited = Map.put(visited, {x, y}, 1 + left_side + right_side)
          {1 + left_side + right_side, visited}

        %TachyonManifoldCell{value: v} when v in [:start, :empty] ->
          simulate_beam_splitting(grid, {x, y + 1}, visited)
      end
    end
  end
end
