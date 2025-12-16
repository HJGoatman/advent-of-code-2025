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
  def part_2(_input) do
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

  defp is_invalid?(val) do
    digits = Integer.digits(val)
    length = digits |> length()
    not_even_length = length |> Integer.is_odd()

    if not_even_length do
      false
    else
      {first_half, second_half} = Enum.split(digits, div(length, 2))

      Integer.undigits(first_half) == Integer.undigits(second_half)
    end
  end
end
