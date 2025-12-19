defprotocol Aoc2025.Utils.Parsable do
  @spec parse(String.t()) :: t()
  def parse(value)
end

defmodule AOC2025.Utils.Grid do
  @enforce_keys [:mod, :num_rows, :num_cols, :values]
  defstruct [:mod, :num_rows, :num_cols, :values]

  @type t :: %__MODULE__{
          mod: module(),
          num_rows: non_neg_integer(),
          num_cols: non_neg_integer(),
          values: %{{non_neg_integer(), non_neg_integer()} => String.Chars.t() | Parsable}
        }

  def parse_grid(mod, input) do
    splits = String.split(input, "\n") |> Enum.filter(fn line -> line != "" end)

    num_cols = splits |> Enum.at(0) |> String.length()

    num_rows =
      splits
      |> length()

    all_equal_width = Enum.all?(splits, fn line -> String.length(line) == num_cols end)

    if !all_equal_width do
      {:error, :not_equal_length}
    else
      values =
        splits
        |> Enum.with_index(fn line, y ->
          line
          |> String.graphemes()
          |> Enum.with_index(fn element, x -> {{x, y}, mod.parse(element)} end)
        end)
        |> Enum.concat()
        |> Map.new()

      {:ok, %__MODULE__{mod: mod, values: values, num_rows: num_rows, num_cols: num_cols}}
    end
  end

  def get(%__MODULE__{values: values, num_cols: num_cols, num_rows: num_rows}, x, y) do
    if x < 0 or y < 0 or x > num_cols - 1 or y > num_rows - 1 do
      nil
    else
      Map.get(values, {x, y})
    end
  end

  defimpl String.Chars do
    alias AOC2025.Utils.Grid

    def to_string(%Grid{num_cols: num_cols, values: values}) do
      "\n" <>
        (values
         |> Enum.map(&String.Chars.to_string/1)
         |> Enum.chunk_every(num_cols)
         |> Enum.join("\n"))
    end
  end
end
