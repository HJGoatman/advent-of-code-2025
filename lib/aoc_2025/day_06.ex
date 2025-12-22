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

    answers = apply_operations(transposed, parsed_operations)
    Logger.debug("answers: #{inspect(answers)}")

    Enum.sum(answers) |> Integer.to_string()
  end

  @impl AOCDay
  def part_2(input) do
    {values, [operations | _]} =
      input
      |> String.split("\n")
      |> Enum.split(-1)

    transposed =
      values
      |> Enum.map(&String.graphemes/1)
      |> Enum.zip_reduce([], fn elements, acc -> [elements | acc] end)
      |> Enum.reverse()

    Logger.debug("transposed: #{inspect(transposed)}")

    parsed_operations =
      operations
      |> String.split()
      |> Enum.map(fn op ->
        case op do
          "+" -> :add
          "*" -> :multiply
        end
      end)

    colwise =
      transposed
      |> Stream.chunk_by(fn c -> Enum.all?(c, fn v -> v == " " end) end)
      |> Stream.filter(fn cs ->
        not Enum.all?(cs, fn c -> Enum.all?(c, fn v -> v == " " end) end)
      end)
      |> Enum.map(fn col ->
        Enum.map(col, fn val ->
          Enum.filter(val, fn digit -> digit != " " end)
          |> Enum.join("")
        end)
        |> Enum.map(&String.to_integer/1)
      end)

    answers = apply_operations(colwise, parsed_operations)
    Logger.debug("answers: #{inspect(answers)}")

    Enum.sum(answers) |> Integer.to_string()
  end

  defp apply_operations(values, operations) do
    Enum.zip(values, operations)
    |> Enum.map(fn {vals, op} ->
      case op do
        :add -> Enum.reduce(vals, 0, &Kernel.+/2)
        :multiply -> Enum.reduce(vals, 1, &Kernel.*/2)
      end
    end)
  end
end
