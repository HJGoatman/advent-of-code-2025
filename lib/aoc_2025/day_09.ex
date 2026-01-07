defmodule AOC2025.Day09 do
  require Logger
  @behaviour AOCDay

  @impl AOCDay
  def part_1(input, _puzzle_type) do
    red_tiles = parse_input(input)

    Logger.debug("red_tiles: #{inspect(red_tiles, pretty: true)}")

    combinations =
      red_tiles
      |> Stream.with_index()
      |> Stream.flat_map(fn {v, i} ->
        red_tiles |> Stream.drop(i + 1) |> Enum.map(fn w -> {v, w} end)
      end)

    largest_area =
      combinations
      |> Stream.map(fn {left, right} -> get_area_of_rectangle(left, right) end)
      |> Enum.max()

    Integer.to_string(largest_area)
  end

  @impl AOCDay
  def part_2(_input, _puzzle_type) do
  end

  defp parse_input(input) do
    input
    |> String.split("\n")
    |> Stream.filter(fn line -> line != "" end)
    |> Stream.map(fn line ->
      String.split(line, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
    end)
    |> Enum.to_list()
  end

  defp get_area_of_rectangle({x1, y1}, {x2, y2}),
    do: (max(x2, x1) - min(x2, x1) + 1) * (max(y2, y1) - min(y2, y1) + 1)
end
