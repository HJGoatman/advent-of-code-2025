defmodule Day01Test do
  alias AOC2025.Day01.Dial
  alias AOC2025.Day01.Rotation

  use ExUnit.Case, async: true

  doctest(AOC2025.Day01)

  test "rotate dial" do
    new_state = Dial.apply_rotation_2(%Rotation{direction: :r, distance: 1000}, {50, 0})
    assert new_state == {50, 10}
  end

  test "dial starting at zero should not register" do
    new_state = Dial.apply_rotation_2(%Rotation{direction: :l, distance: 5}, {0, 1})
    assert new_state == {95, 1}
  end

  test "dial should recognise it points at zero" do
    new_state = Dial.apply_rotation_2(%Rotation{direction: :l, distance: 50}, {50, 0})
    assert new_state == {0, 1}
  end

  test "example should work correctly" do
    expected_states = [
      {82, 1},
      {52, 1},
      {0, 2},
      {95, 2},
      {55, 3},
      {0, 4},
      {99, 4},
      {0, 5},
      {14, 5},
      {32, 6}
    ]

    rotations = [
      %Rotation{direction: :l, distance: 68},
      %Rotation{direction: :l, distance: 30},
      %Rotation{direction: :r, distance: 48},
      %Rotation{direction: :l, distance: 5},
      %Rotation{direction: :r, distance: 60},
      %Rotation{direction: :l, distance: 55},
      %Rotation{direction: :l, distance: 1},
      %Rotation{direction: :l, distance: 99},
      %Rotation{direction: :r, distance: 14},
      %Rotation{direction: :l, distance: 82}
    ]

    Enum.zip(rotations, expected_states)
    |> Enum.reduce({50, 0}, fn {rotation, expected}, acc ->
      new_state = Dial.apply_rotation_2(rotation, acc)
      assert expected == new_state
      new_state
    end)
  end
end
