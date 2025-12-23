defmodule AOC2025.Day08 do
  require Logger
  @behaviour AOCDay

  @impl AOCDay
  def part_1(input) do
    junction_box_positions =
      String.split(input, "\n")
      |> Stream.filter(fn line -> line != "" end)
      |> Stream.map(fn line ->
        String.split(line, ",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> Enum.with_index()

    Logger.debug("#{inspect(junction_box_positions, pretty: true)}")

    potiential_wires =
      junction_box_positions
      |> Stream.flat_map(fn {position_a, index} ->
        junction_box_positions
        |> Stream.drop(index + 1)
        |> Stream.map(fn position_b -> {{position_a, index}, position_b} end)
      end)

    sorted_distances =
      potiential_wires
      |> Stream.map(fn {{{p1, p2, p3}, _}, {{q1, q2, q3}, _}} ->
        (q1 - p1) ** 2 + (q2 - p2) ** 2 + (q3 - p3) ** 2
      end)
      |> Stream.zip(potiential_wires)
      |> Enum.sort()

    Logger.debug("sorted distances: #{inspect(sorted_distances, limit: 150, pretty: true)}")

    num_connections = 1000

    {circuits, _} =
      sorted_distances
      |> Stream.take(num_connections)
      |> Stream.map(&elem(&1, 1))
      |> find_circuits(num_connections)

    Logger.debug("circuits: #{inspect(circuits, pretty: true)}")

    circuit_sizes =
      circuits
      |> Stream.map(&Kernel.length/1)
      |> Stream.zip(circuits)
      |> Enum.sort()
      |> Enum.reverse()

    Logger.debug("circuit_sizes: #{inspect(circuit_sizes, pretty: true)}")

    circuit_sizes
    |> Stream.take(3)
    |> Stream.map(&elem(&1, 0))
    |> Enum.product()
    |> Integer.to_string()
  end

  @impl AOCDay
  def part_2(input) do
  end

  defp find_circuit_containing_junction_box(circuits, junction_box) do
    circuits |> Enum.find_index(fn circuit -> junction_box in circuit end)
  end

  defp find_circuits(wires, max_connections) do
    Enum.reduce(wires, {[], 0}, fn wire, {circuits, num_connections} ->
      Logger.debug("wire: #{inspect(wire)}")
      Logger.debug("circuit: #{inspect(circuits)}", pretty: true)

      {junction_box_a, junction_box_b} = wire

      circuit_index_a = find_circuit_containing_junction_box(circuits, junction_box_a)
      circuit_index_b = find_circuit_containing_junction_box(circuits, junction_box_b)

      cond do
        num_connections == max_connections ->
          {circuits, num_connections}

        circuit_index_a == nil and circuit_index_b == nil ->
          {[[junction_box_a, junction_box_b] | circuits], num_connections + 1}

        circuit_index_a != nil and circuit_index_b == nil ->
          new_circuits =
            List.update_at(circuits, circuit_index_a, fn circuit_with_a ->
              [junction_box_b | circuit_with_a]
            end)

          {new_circuits, num_connections + 1}

        circuit_index_b != nil and circuit_index_a == nil ->
          new_circuits =
            List.update_at(circuits, circuit_index_b, fn circuit_with_b ->
              [junction_box_a | circuit_with_b]
            end)

          {new_circuits, num_connections + 1}

        circuit_index_a == circuit_index_b ->
          {circuits, num_connections}

        circuit_index_a != circuit_index_b ->
          Logger.debug("merging circuits")
          {circuit_b, circuits_without_b} = List.pop_at(circuits, circuit_index_b)

          new_index_a =
            if circuit_index_b < circuit_index_a do
              circuit_index_a - 1
            else
              circuit_index_a
            end

          new_circuits =
            List.update_at(circuits_without_b, new_index_a, fn circuit_with_a ->
              circuit_with_a ++ circuit_b
            end)

          {new_circuits, num_connections + 1}
      end
    end)
  end
end
