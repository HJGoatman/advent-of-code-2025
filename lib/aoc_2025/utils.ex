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

  def find_position(%__MODULE__{values: values}, fun) do
    values |> Enum.find(fn {_, value} -> fun.(value) end) |> elem(0)
  end

  defimpl String.Chars do
    alias AOC2025.Utils.Grid

    def to_string(%Grid{num_rows: num_rows, num_cols: num_cols} = grid) do
      points =
        0..(num_rows - 1)
        |> Enum.flat_map(fn y -> Enum.map(0..(num_cols - 1), fn x -> {x, y} end) end)
        |> Enum.map(fn {x, y} -> Grid.get(grid, x, y) end)

      "\n" <>
        (points
         |> Enum.map(&String.Chars.to_string/1)
         |> Enum.chunk_every(num_cols)
         |> Enum.join("\n"))
    end
  end

  def breadth_first_search(initial_value, directions) do
    Stream.resource(
      fn ->
        queue = :queue.new()
        queue = :queue.in(initial_value, queue)

        visited = MapSet.new()
        {queue, visited}
      end,
      fn {queue, visited} ->
        case :queue.out(queue) do
          {{:value, value}, queue} ->
            if not MapSet.member?(visited, value) do
              visited = MapSet.put(visited, value)

              queue =
                directions
                |> Enum.reduce(queue, fn direction, queue ->
                  next_value = get_next(value, direction)

                  :queue.in(next_value, queue)
                end)

              {[value], {queue, visited}}
            else
              {[], {queue, visited}}
            end

          {:empty, queue} ->
            {:halt, queue}
        end
      end,
      fn _queue -> nil end
    )
  end

  defp get_next({x, y}, :left), do: {x - 1, y}
  defp get_next({x, y}, :up), do: {x, y + 1}
  defp get_next({x, y}, :right), do: {x + 1, y}
  defp get_next({x, y}, :down), do: {x, y - 1}
end
