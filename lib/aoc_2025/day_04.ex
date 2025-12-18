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

    Logger.debug("#{Grid.get(grid, 10, 0)}")
    Logger.debug("#{grid}")

    ys = 0..(grid.num_rows - 1)
    xs = 0..(grid.num_cols - 1)

    coordinates = Stream.flat_map(ys, fn y -> Stream.map(xs, fn x -> {x, y} end) end)

    rolls_of_paper_coordinates =
      coordinates
      |> Stream.filter(fn {x, y} ->
        Grid.get(grid, x, y) == %PaperCell{value: :paper}
      end)
      |> Enum.to_list()

    Logger.debug("rolls_of_paper_coordinates: #{inspect(rolls_of_paper_coordinates)}")

    num_rolls_around =
      Stream.map(rolls_of_paper_coordinates, fn {x, y} ->
        get_points_around({x, y})
        |> Stream.filter(fn {ax, ay} ->
          Grid.get(grid, ax, ay) == %PaperCell{value: :paper}
        end)
        |> Enum.count()
      end)
      |> Enum.to_list()
      |> Enum.zip(rolls_of_paper_coordinates)

    Logger.debug("num_around: #{inspect(num_rolls_around)}")

    accessable_rolls_coordinates =
      num_rolls_around
      |> Enum.filter(fn {num_around, _} -> num_around < @part_1_min_num_rols end)

    Logger.debug("#{inspect(accessable_rolls_coordinates)}")

    Integer.to_string(accessable_rolls_coordinates |> Enum.count())
  end

  @impl AOCDay
  def part_2(_input) do
    ""
  end

  defp get_points_around({px, py}) do
    xs = -1..1
    ys = -1..1

    diff =
      ys
      |> Stream.flat_map(fn y -> Stream.map(xs, fn x -> {x, y} end) end)
      |> Stream.filter(fn {x, y} -> not (x == 0 and y == 0) end)
      |> Enum.to_list()

    Stream.map(diff, fn {x, y} -> {px + x, py + y} end)
  end
end
