defmodule AOC2025.Day02 do
  require Integer
  require Logger

  @behaviour AOCDay

  @impl AOCDay
  def part_1(input) do
    id_ranges = parse_input(input)

    Logger.info("id ranges: #{inspect(id_ranges)}")

    invalid_id_ranges =
      Stream.flat_map(id_ranges, fn rng ->
        Stream.filter(rng, &is_invalid?/1)
      end)

    Enum.sum(invalid_id_ranges) |> Integer.to_string()
  end

  @impl AOCDay
  def part_2(input) do
    id_ranges = parse_input(input)

    invalid_id_ranges =
      Stream.flat_map(id_ranges, fn rng ->
        Stream.filter(rng, fn a -> is_invalid?(a, 2, nil) end)
      end)
      |> Enum.to_list()

    Logger.debug("#{inspect(invalid_id_ranges)}")

    Enum.sum(invalid_id_ranges) |> Integer.to_string()
  end

  defp parse_input(input) do
    String.split(input, ",")
    |> Enum.map(fn id_range ->
      [first, last] = String.split(id_range, "-", parts: 2)
      {first, _} = Integer.parse(first)
      {last, _} = Integer.parse(last)

      first..last
    end)
  end

  defp is_invalid?(val, min_chunks \\ 2, max_chunks \\ 2) do
    digits = Integer.digits(val)
    length = digits |> length()

    max = min(length, max_chunks)

    if min_chunks > max do
      false
    else
      Enum.any?(min_chunks..max, fn num_chunks ->
        has_remainder = rem(length, num_chunks) != 0

        if has_remainder do
          false
        else
          chunk_size = div(length, num_chunks)

          chunks =
            Enum.chunk_every(digits, chunk_size, chunk_size, :discard)
            |> Enum.map(&Integer.undigits/1)

          offset = Enum.drop(chunks, 1)

          Enum.zip(offset, chunks)
          |> Enum.all?(fn {curr, prev} -> curr == prev end)
        end
      end)
    end
  end
end
