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
        red_tiles |> Stream.drop(i + 1) |> Stream.map(fn w -> {v, w} end)
      end)

    largest_area =
      combinations
      |> Stream.map(fn {left, right} -> get_area_of_rectangle(left, right) end)
      |> Enum.max()

    Integer.to_string(largest_area)
  end

  @impl AOCDay
  def part_2(input, _puzzle_type) do
    red_tiles = parse_input(input)

    all_tiles = fill_green_tiles(red_tiles)

    Logger.debug("all_tiles: #{inspect(all_tiles, pretty: true, limit: :infinity)}")
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

  defp fill_green_tiles(red_tiles) do
    red_tiles
    |> add_green_boundary()
    |> fill_inside()
  end

  defp add_green_boundary(red_tiles) do
    tiles =
      red_tiles
      |> Enum.reduce([], fn red_tile, tiles ->
        tiles =
          case tiles do
            [{previous_red_tile, :red} | _] ->
              new_green =
                get_tiles_between(previous_red_tile, red_tile)
                |> Enum.reverse()
                |> Enum.map(fn tile -> {tile, :green} end)

              new_green ++ tiles

            [] ->
              tiles
          end

        [{red_tile, :red} | tiles]
      end)

    [first_red | _] = red_tiles
    [{last_red, _} | _] = tiles

    final_green =
      get_tiles_between(last_red, first_red)
      |> Enum.reverse()
      |> Enum.map(fn tile -> {tile, :green} end)

    final_green ++ tiles
  end

  defp fill_inside(tiles) do
    first_green = tiles |> Enum.find(fn t -> elem(t, 1) == :green end)
  end

  defp get_tiles_between({x1, y1}, {x2, y2}) when x1 == x2 and y2 > y1 do
    (y1 + 1)..(y2 - 1) |> Enum.map(fn y -> {x1, y} end)
  end

  defp get_tiles_between({x1, y1}, {x2, y2}) when x1 == x2 and y1 > y2 do
    (y1 - 1)..(y2 + 1) |> Enum.map(fn y -> {x1, y} end)
  end

  defp get_tiles_between({x1, y1}, {x2, y2}) when y1 == y2 and x2 > x1 do
    (x1 + 1)..(x2 - 1) |> Enum.map(fn x -> {x, y1} end)
  end

  defp get_tiles_between({x1, y1}, {x2, y2}) when y1 == y2 and x1 > x2 do
    (x1 - 1)..(x2 + 1) |> Enum.map(fn x -> {x, y1} end)
  end
end
