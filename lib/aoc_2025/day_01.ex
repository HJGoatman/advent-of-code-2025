defmodule AOC2025.Day01 do
  @starting_position 50
  @max_dial_value 100

  def part_1() do
    input = read_input()
    rotations = parse_input(input)
    initial_state = {@starting_position, 0}
    {_, times_at_zero} = rotations |> Enum.reduce(initial_state, &apply_rotation/2)
    IO.puts(times_at_zero)
  end

  def part_2() do
  end

  defp read_input() do
    priv_dir = :code.priv_dir(:aoc_2025)
    input_filepath = Path.join([priv_dir, "inputs", "day_01.txt"])
    {:ok, input} = File.read(input_filepath)
    input
  end

  defp parse_input(input) do
    String.split(input, "\n")
    |> Enum.filter(fn x -> x != "" end)
    |> Enum.map(fn x -> __MODULE__.Rotation.parse(x) end)
  end

  defp apply_rotation(rotation, state) do
    {position, times_at_zero} = state

    new_position =
      case(rotation.direction) do
        :l ->
          rem(
            rem(position - rotation.distance, @max_dial_value) + @max_dial_value,
            @max_dial_value
          )

        :r ->
          rem(position + rotation.distance, @max_dial_value)
      end

    new_times_at_0 =
      if new_position == 0 do
        times_at_zero + 1
      else
        times_at_zero
      end

    {new_position, new_times_at_0}
  end
end

defmodule AOC2025.Day01.Rotation do
  defstruct [:direction, :distance]

  @rotation_split 1

  def parse(plaintext) do
    {direction_text, amount_text} = String.split_at(plaintext, @rotation_split)
    {:ok, direction} = parse_direction(direction_text)
    {amount, _} = Integer.parse(amount_text)
    %__MODULE__{direction: direction, distance: amount}
  end

  defp parse_direction(plaintext) do
    case plaintext do
      "R" -> {:ok, :r}
      "L" -> {:ok, :l}
      _ -> {:error, :unknown_direction, plaintext}
    end
  end
end
