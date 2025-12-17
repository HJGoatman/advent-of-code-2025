defmodule AOC2025.Day03 do
  require Logger
  @behaviour AOCDay

  @impl AOCDay
  def part_1(input) do
    banks = parse_input(input)
    Logger.debug("banks: #{inspect(banks)}")

    batteries_to_turn_on = banks |> Enum.map(&find_batteries_to_turn_on/1)
    Logger.debug("batteries: #{inspect(batteries_to_turn_on, charlists: :as_lists)}")

    Enum.sum(batteries_to_turn_on) |> Integer.to_string()
  end

  @impl AOCDay
  def part_2(_input) do
  end

  defp parse_input(input) do
    input |> String.split("\n") |> Enum.filter(fn v -> v != "" end) |> Enum.map(&parse_bank/1)
  end

  defp parse_bank(input) do
    {i, _rem} = Integer.parse(input)
    Integer.digits(i)
  end

  @spec find_batteries_to_turn_on([integer()]) :: integer()
  defp find_batteries_to_turn_on(bank) do
    bank
    |> Enum.reverse()
    |> Enum.reduce({nil, nil}, fn battery, {left, right} ->
      cond do
        right == nil ->
          {left, battery}

        left == nil ->
          {battery, right}

        battery > left ->
          if left > right do
            {battery, left}
          else
            {battery, right}
          end

        battery == left ->
          if battery > right do
            {left, battery}
          else
            {left, right}
          end

        true ->
          {left, right}
      end
    end)
    |> Tuple.to_list()
    |> Integer.undigits()
  end
end
