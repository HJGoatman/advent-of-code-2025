defmodule AOC2025 do
  @moduledoc """
  Documentation for `Aoc2025`.
  """

  @inputs_dir Path.join([:code.priv_dir(:aoc_2025), "inputs"])

  def run(opts \\ []) do
    opts =
      Enum.into(opts, %{
        year: 2025,
        day: nil,
        part: nil,
        all: false,
        input: :puzzle
      })

    cond do
      opts.all -> run_all(opts)
      opts.day -> run_day(opts.year, opts.day, opts.part, opts.input)
    end
  end

  defp run_all(opts) do
    days = available_days()

    results =
      for day <- days do
        {day, run_day(opts.year, day, nil, opts.input, capture: true)}
      end

    IO.puts("\nSummary")

    Enum.each(results, fn {day, %{times: times}} ->
      IO.puts("Day #{pad(day)}: part1 #{ms(times.part1)}  part2 #{ms(times.part2)}")
    end)
  end

  defp run_day(year, day, part, input_type, opts \\ []) do
    day = normalize_day(day)
    mod = day_module(year, day)
    input = load_input(year, day, input_type)

    run_part = fn p ->
      if part && part != p,
        do: {:skipped, nil},
        else: timed(fn -> apply(mod, :"part_#{p}", [input, input_type]) end)
    end

    res1 = run_part.(1)
    res2 = run_part.(2)

    result = %{
      day: day,
      module: mod,
      part1: format_result(res1),
      part2: format_result(res2),
      times: %{part1: time_ms(res1), part2: time_ms(res2)}
    }

    unless opts[:capture], do: print_result(result)
    result
  end

  defp print_result(%{day: day, part1: p1, part2: p2, times: times}) do
    IO.puts("Day #{pad(day)}")
    IO.puts("  Part 1: #{p1}  (#{ms(times.part1)})")
    IO.puts("  Part 2: #{p2}  (#{ms(times.part2)})")
  end

  # Helpers
  defp day_module(year, day) do
    Module.concat([:"AOC#{year}", :"Day#{pad(day)}"])
  end

  defp normalize_day(d) when is_integer(d), do: d

  defp normalize_day(<<d::binary>>) do
    {i, _} = Integer.parse(d)
    i
  end

  defp pad(n) when n < 10, do: "0#{n}"
  defp pad(n), do: "#{n}"

  defp timed(fun) do
    {time, result} = :timer.tc(fn -> fun.() end)
    {result, time}
  end

  defp time_ms({:skipped, _}), do: 0
  defp time_ms({_, ms}), do: ms

  defp ms(0), do: "0.0ms"
  defp ms(ms) when is_integer(ms), do: "#{ms}"

  defp format_result({:skipped, _}), do: "skipped"
  defp format_result({result, _}), do: inspect(result)

  defp load_input(_year, day, :example) do
    path = Path.join(@inputs_dir, "day_#{pad(day)}_example.txt")
    File.read!(path)
  end

  defp load_input(_year, day, :puzzle) do
    path = Path.join(@inputs_dir, "day_#{pad(day)}.txt")
    File.read!(path)
  end

  defp available_days() do
    case File.ls(@inputs_dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&Regex.match?(~r/day\d{2}\.txt$/, &1))
        |> Enum.map(fn f ->
          [_, num] = Regex.run(~r/day(\d{2})\.txt$/, f)
          String.to_integer(num)
        end)
        |> Enum.sort()

      _ ->
        []
    end
  end
end

defmodule AOCDay do
  @callback part_1(String.t(), Atom.t()) :: String.t()
  @callback part_2(String.t(), Atom.t()) :: String.t()
end
