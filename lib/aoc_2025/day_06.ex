defmodule AOC2025.Day06 do
  require Logger
  @behaviour AOCDay

  @impl AOCDay
  def part_1(input) do
    {values, [operations | _]} =
      String.split(input, "\n")
      |> Stream.map(&String.split/1)
      |> Enum.split(-1)

    numerical_values = values |> Enum.map(fn row -> Enum.map(row, &String.to_integer/1) end)

    parsed_operations =
      operations
      |> Enum.map(fn op ->
        case op do
          "+" -> :add
          "*" -> :multiply
        end
      end)

    transposed =
      numerical_values
      |> Enum.zip_reduce([], fn elements, acc -> [elements | acc] end)
      |> Enum.reverse()

    Logger.debug("transposed: #{inspect(transposed)}")

    answers =
      Enum.zip(transposed, parsed_operations)
      |> Enum.map(fn {vals, op} ->
        case op do
          :add -> Enum.reduce(vals, 0, &Kernel.+/2)
          :multiply -> Enum.reduce(vals, 1, &Kernel.*/2)
        end
      end)

    Logger.debug("answers: #{inspect(answers)}")

    Enum.sum(answers) |> Integer.to_string()
  end

  @impl AOCDay
  def part_2(input) do
  end
end
