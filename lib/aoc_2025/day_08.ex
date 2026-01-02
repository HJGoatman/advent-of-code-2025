defmodule AOC2025.Day08 do
  require Logger
  @behaviour AOCDay

  @impl AOCDay
  def part_1(input, input_type) do
    junction_box_positions = parse_input(input)
    Logger.debug("#{inspect(junction_box_positions, pretty: true)}")

    Logger.debug("num_junctions: #{length(junction_box_positions)}")

    sorted_distances = calculate_shortest_connections(junction_box_positions)
    Logger.debug("sorted distances: #{inspect(sorted_distances, limit: 150, pretty: true)}")

    num_connections =
      case input_type do
        :example -> 10
        :puzzle -> 1000
      end

    connections = create_new_adjancey_list(junction_box_positions)
    Logger.debug("connections: #{inspect(connections)}")

    connections = make_connections(connections, sorted_distances |> Enum.take(num_connections))
    Logger.debug("connections: #{inspect(connections, pretty: true, charlists: :as_lists)}")

    actual_num_conections = connections |> Enum.map(fn {_, v} -> length(v) end) |> Enum.sum()
    Logger.debug("actual_num_conections: #{actual_num_conections}")

    circuits = find_circuits(connections, Map.keys(connections))

    Logger.debug("circuits: #{inspect(circuits, pretty: true, charlists: :as_lists)}")

    circuit_sizes =
      circuits
      |> Enum.map(&Kernel.length/1)
      |> Enum.zip(circuits)
      |> Enum.sort()
      |> Enum.reverse()

    Logger.debug("circuit_sizes: #{inspect(circuit_sizes, pretty: true, charlists: :as_lists)}")

    circuit_sizes
    |> Stream.take(3)
    |> Stream.map(&elem(&1, 0))
    |> Enum.product()
    |> Integer.to_string()
  end

  @impl AOCDay
  def part_2(input, _input_type) do
    junction_box_positions = parse_input(input)
    Logger.debug("#{inspect(junction_box_positions, pretty: true)}")

    Logger.debug("num_junctions: #{length(junction_box_positions)}")

    sorted_distances = calculate_shortest_connections(junction_box_positions)
    Logger.debug("sorted distances: #{inspect(sorted_distances, limit: 150, pretty: true)}")

    connections = create_new_adjancey_list(junction_box_positions)
    Logger.debug("connections: #{inspect(connections)}")

    connections_made =
      connect_all_junctions(connections, sorted_distances)

    Logger.debug(
      "connections_made: #{inspect(length(connections_made), pretty: true, limit: :infinity)}"
    )

    [last_connection_made | _rest] = connections_made |> Enum.reverse() |> Enum.drop(1)

    {left_id, right_id} = last_connection_made

    [{left_junction_box_position, _}, {right_junction_box_position, _}] =
      junction_box_positions
      |> Enum.filter(fn {_, position} -> position == left_id or position == right_id end)
      |> Enum.to_list()

    (elem(left_junction_box_position, 0) * elem(right_junction_box_position, 0))
    |> Integer.to_string()
  end

  defp parse_input(input) do
    String.split(input, "\n")
    |> Stream.filter(fn line -> line != "" end)
    |> Stream.map(fn line ->
      String.split(line, ",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.with_index()
  end

  defp calculate_shortest_connections(junction_box_positions) do
    potiential_wires =
      junction_box_positions
      |> Enum.flat_map(fn {position_a, index} ->
        junction_box_positions
        |> Stream.drop(index + 1)
        |> Enum.map(fn position_b -> {{position_a, index}, position_b} end)
        |> Enum.to_list()
      end)
      |> Enum.to_list()

    sorted_distances =
      potiential_wires
      |> Stream.map(fn {{{p1, p2, p3}, _}, {{q1, q2, q3}, _}} ->
        (q1 - p1) ** 2 + (q2 - p2) ** 2 + (q3 - p3) ** 2
      end)
      |> Stream.zip(potiential_wires)
      |> Enum.sort()
      |> Enum.map(fn {_, {{_, id_a}, {_, id_b}}} -> {id_a, id_b} end)
      |> Enum.to_list()

    sorted_distances
  end

  defp create_new_adjancey_list(junction_box_positions) do
    0..(length(junction_box_positions) - 1) |> Range.to_list() |> Map.from_keys([])
  end

  defp is_connected?(connections, a, b, visited \\ [])

  defp is_connected?(_connections, a, b, _visited) when a == b, do: true

  defp is_connected?(connections, a, b, visited) do
    current_connections_a = connections |> Map.get(a)

    current_connections_a
    |> Stream.filter(fn connection -> connection not in visited end)
    |> Enum.any?(fn connection -> is_connected?(connections, connection, b, [a | visited]) end)
  end

  defp find_connections(_connections, _junctions, _visitied \\ [])

  defp find_connections(connections, junction, visited) do
    if junction in visited do
      visited
    else
      connected =
        Map.get(connections, junction)
        |> Enum.filter(fn j -> j not in visited end)

      Enum.reduce(connected, [junction | visited], fn connection, connects ->
        find_connections(connections, connection, connects)
      end)
    end
  end

  defp make_connections(connections, []), do: connections

  defp make_connections(connections, wires) do
    [{junction_box_a, junction_box_b} | remaining_wires] = wires
    new_connections = add_connection(connections, junction_box_a, junction_box_b)

    make_connections(new_connections, remaining_wires)
  end

  defp make_connection(connections, []), do: {connections, [], nil}

  defp make_connection(connections, wires) do
    [wire | remaining_wires] = wires
    {junction_box_a, junction_box_b} = wire

    is_a_connected_to_b = is_connected?(connections, junction_box_a, junction_box_b)

    if not is_a_connected_to_b do
      new_connections = add_connection(connections, junction_box_a, junction_box_b)
      {new_connections, remaining_wires, wire}
    else
      make_connection(connections, remaining_wires)
    end
  end

  defp add_connection(connections, junction_box_a, junction_box_b) do
    connections
    |> Map.update!(junction_box_a, fn a_connections ->
      [junction_box_b | a_connections]
    end)
    |> Map.update!(junction_box_b, fn b_connections ->
      [junction_box_a | b_connections]
    end)
  end

  defp find_circuits(connections, unvisited)

  defp find_circuits(_connections, []), do: []

  defp find_circuits(connections, unvisited) do
    [first_junction | rest] = unvisited

    connected_to_first = find_connections(connections, first_junction)
    rest = rest |> Enum.filter(fn connection -> connection not in connected_to_first end)

    [
      connected_to_first
      | find_circuits(
          connections,
          rest
        )
    ]
  end

  defp connect_all_junctions(_connections, []) do
    []
  end

  defp connect_all_junctions(connections, wires) do
    {new_connections, new_wires, connection_made} = make_connection(connections, wires)

    [connection_made | connect_all_junctions(new_connections, new_wires)]
  end
end
