defmodule CalculationTest do
  use ExUnit.Case
  alias StlAnalyzer.Calculations

  doctest StlAnalyzer.Calculations

  describe "bounding_box/2" do
    test "happy path with example input" do
      lower = {0, 0, 0}
      upper = {1, 1, 1}

      expected = [
        {1, 0, 0},
        {1, 0, 1},
        {0, 0, 0},
        {0, 0, 1},
        {1, 1, 0},
        {1, 1, 1},
        {0, 1, 0},
        {0, 1, 1}
      ]

      assert Calculations.bounding_box(lower, upper) == expected
    end
  end

  describe "surface_area/3" do
    test "happy path with first facet from example input" do
      v1 = {0, 0, 0}
      v2 = {1, 0, 0}
      v3 = {1, 1, 1}

      assert Calculations.surface_area(v1, v2, v3) == 0.7071067811865476
    end

    test "happy path with second facet from example input" do
      v1 = {0, 0, 0}
      v2 = {0, 1, 1}
      v3 = {1, 1, 1}

      assert Calculations.surface_area(v1, v2, v3) == 0.7071067811865476
    end

    test "happy path with first facet from large example input" do
      v1 = {-9.31197, -11.9214, 10.3729}
      v2 = {-9.32778, -11.9504, 10.4318}
      v3 = {-9.3279, -11.9535, 10.4323}

      assert Calculations.surface_area(v1, v2, v3) == 8.707471020625466e-5
    end
  end
end
