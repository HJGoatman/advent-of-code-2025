defmodule AOC2025.Day05 do
  require Logger
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
  def part_2(input) do
    {fresh_ingredient_ranges, _} = parse_input(input)

    compressed_ranges =
      compress_range_list(fresh_ingredient_ranges)

    Logger.debug("compressed ranges: #{inspect(compressed_ranges)}")

    compressed_ranges
    |> Enum.reduce(0, fn rng, acc -> acc + Range.size(rng) end)
    |> Integer.to_string()
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
    String.split(input, "\n")
    |> Stream.map(&parse_ingredient_range/1)
    |> Enum.to_list()
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

  defp compress_range_list(ranges) do
    ordered_ranges =
      ranges
      |> Stream.flat_map(fn first..last//1 ->
        [{first, :first}, {last, :last}]
      end)
      |> Enum.sort()

    initial_state = {[], 0}

    {compressed, 0} =
      ordered_ranges
      |> Enum.reduce(initial_state, &build_compressed_list/2)

    compressed
    |> Enum.reverse()
    |> Enum.chunk_every(2)
    |> Enum.map(fn [{first, :first}, {last, :last}] -> first..last end)
  end

  defp build_compressed_list({value, :first}, {compressed, 0}),
    do: {[{value, :first} | compressed], 1}

  defp build_compressed_list({value, :last}, {compressed, 1}),
    do: {[{value, :last} | compressed], 0}

  defp build_compressed_list({_, :first}, {compressed, val}), do: {compressed, val + 1}
  defp build_compressed_list({_, :last}, {compressed, val}), do: {compressed, val - 1}
end
