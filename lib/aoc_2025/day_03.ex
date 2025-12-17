defmodule AOC2025.Day03 do
  require Logger
  @behaviour AOCDay

  @impl AOCDay
  def part_1(input) do
    solve_part(input)
  end

  @part_2_num_batteries 12

  @impl AOCDay
  def part_2(input) do
    solve_part(input, @part_2_num_batteries)
  end

  def solve_part(input, num_batteries \\ 2) do
    banks = parse_input(input)
    Logger.debug("banks: #{inspect(banks)}")

    batteries_to_turn_on =
      banks |> Enum.map(fn battery -> find_batteries_to_turn_on(battery, num_batteries) end)

    Logger.debug("batteries: #{inspect(batteries_to_turn_on, charlists: :as_lists)}")

    Enum.sum(batteries_to_turn_on) |> Integer.to_string()
  end

  defp parse_input(input) do
    input |> String.split("\n") |> Enum.filter(fn v -> v != "" end) |> Enum.map(&parse_bank/1)
  end

  defp parse_bank(input) do
    {i, _rem} = Integer.parse(input)
    Integer.digits(i)
  end

  @spec find_batteries_to_turn_on([integer()]) :: integer()
  defp find_batteries_to_turn_on(bank, num_batteries \\ 2) do
    {remaining_bank, initial_state} = bank |> Enum.split(length(bank) - num_batteries)

    remaining_bank
    |> Enum.reverse()
    |> Enum.reduce(initial_state, &handle_new_battery/2)
    |> Integer.undigits()
  end

  def handle_new_battery(_, state) when state == [], do: []

  def handle_new_battery(battery, state) do
    Logger.debug("battery, state: #{battery}, #{inspect(state)}")
    [first | rest] = state

    cond do
      first == nil ->
        [battery | rest]

      battery >= first ->
        [battery | handle_new_battery(first, rest)]

      true ->
        state
    end
  end
end
