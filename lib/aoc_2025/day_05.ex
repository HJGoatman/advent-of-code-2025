defmodule AOC2025.Day05 do
  @behaviour AOCDay

  @impl AOCDay
  def part_1(input) do
    {fresh_ingredient_ranges, available_ingredient_ids} = parse_input(input)

    num_avialable =
      available_ingredient_ids
      |> Stream.filter(fn available_ingredient_id ->
        Enum.any?(fresh_ingredient_ranges, fn fresh_ingredient_range ->
          available_ingredient_id in fresh_ingredient_range
        end)
      end)
      |> Enum.count()

    Integer.to_string(num_avialable)
  end

  @impl AOCDay
  def part_2(_input) do
    "hi"
  end

  defp parse_input(input) do
    [fresh_ingredient_ranges_str, available_ingredient_ids_str] =
      String.split(input, "\n\n", parts: 2)

    fresh_ingredient_ranges = parse_fresh_ingredient_ranges(fresh_ingredient_ranges_str)

    available_ingredient_ids =
      parse_available_ingredient_ids(available_ingredient_ids_str)

    {fresh_ingredient_ranges, available_ingredient_ids}
  end

  defp parse_fresh_ingredient_ranges(input) do
    String.split(input, "\n") |> Stream.map(&parse_ingredient_range/1) |> Enum.to_list()
  end

  defp parse_ingredient_range(ingredient_range) do
    [first, last] =
      String.split(ingredient_range, "-", parts: 2)
      |> Stream.map(&String.to_integer/1)
      |> Enum.to_list()

    Range.new(first, last)
  end

  defp parse_available_ingredient_ids(input) do
    String.split(input, "\n")
    |> Stream.filter(fn s -> s != "" end)
    |> Stream.map(&String.to_integer/1)
    |> Enum.to_list()
  end
end
