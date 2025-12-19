defmodule AOC2025.Day04.PaperCell do
  @enforce_keys [:value]
  defstruct [:value]

  def parse(input) do
    value =
      case input do
        "@" -> :paper
        "." -> :empty
      end

    %AOC2025.Day04.PaperCell{value: value}
  end

  defimpl String.Chars do
    def to_string(%AOC2025.Day04.PaperCell{value: value}) do
      case value do
        :paper -> "@"
        :empty -> "."
      end
    end
  end
end

defmodule AOC2025.Day04 do
  alias AOC2025.Utils.Grid
  alias AOC2025.Day04.PaperCell

  require Logger

  @behaviour AOCDay

  @part_1_min_num_rols 4

  @impl AOCDay
  def part_1(input) do
    {:ok, grid} = Grid.parse_grid(PaperCell, input)
    Logger.debug("#{grid.num_cols}")
    Logger.debug("#{grid}")

    roll_coordinates = get_paper_roll_coordinates(grid)
    accessable_rolls_coordinates = get_accessible_rolls(grid, roll_coordinates)
    Logger.debug("#{inspect(accessable_rolls_coordinates)}")

    Integer.to_string(accessable_rolls_coordinates |> Enum.count())
  end

  @impl AOCDay
  def part_2(input) do
    {:ok, grid} = Grid.parse_grid(PaperCell, input)
    roll_coordinates = get_paper_roll_coordinates(grid)
    rolls = remove_all_rolls(grid, roll_coordinates, MapSet.new())
    Integer.to_string(rolls |> Enum.count())
  end

  defp remove_all_rolls(grid, roll_coordinates, removed_rolls) do
    new_removed_rolls = get_accessible_rolls(grid, roll_coordinates, removed_rolls)

    # Logger.info("#{inspect(new_removed_rolls)}")

    if new_removed_rolls |> MapSet.size() == 0 do
      removed_rolls
    else
      remove_all_rolls(
        grid,
        MapSet.difference(roll_coordinates, new_removed_rolls),
        MapSet.union(removed_rolls, new_removed_rolls)
      )
    end
  end

  defp get_paper_roll_coordinates(grid) do
    ys = 0..(grid.num_rows - 1)
    xs = 0..(grid.num_cols - 1)

    coordinates =
      Stream.flat_map(ys, fn y -> Stream.map(xs, fn x -> {x, y} end) end)

    rolls_of_paper_coordinates =
      coordinates
      |> Stream.filter(fn {x, y} ->
        Grid.get(grid, x, y) == %PaperCell{value: :paper}
      end)
      |> MapSet.new()

    rolls_of_paper_coordinates
  end

  defp get_accessible_rolls(grid, rolls_of_paper_coordinates, ignore_coordinates \\ MapSet.new()) do
    num_rolls_around =
      Stream.map(rolls_of_paper_coordinates, fn coord ->
        {get_num_rolls_around(grid, ignore_coordinates, coord), coord}
      end)

    accessable_rolls_coordinates =
      num_rolls_around
      |> Stream.filter(fn {num_around, _} -> num_around < @part_1_min_num_rols end)
      |> Stream.map(fn {_, coord} -> coord end)
      |> MapSet.new()

    accessable_rolls_coordinates
  end

  defp get_num_rolls_around(grid, ignore_coordinates, coord) do
    get_points_around(coord)
    |> Stream.filter(fn {ax, ay} ->
      Grid.get(grid, ax, ay) == %PaperCell{value: :paper}
    end)
    |> Stream.filter(fn coordinate -> not MapSet.member?(ignore_coordinates, coordinate) end)
    |> Enum.count()
  end

  defp get_points_around({px, py}) do
    xs = -1..1
    ys = -1..1

    diff =
      ys
      |> Stream.flat_map(fn y -> Stream.map(xs, fn x -> {x, y} end) end)
      |> Stream.filter(fn {x, y} -> not (x == 0 and y == 0) end)

    Stream.map(diff, fn {x, y} -> {px + x, py + y} end)
  end
end
