defmodule StlAnalyzerViewClieTest do
  use ExUnit.Case

  describe "build/1" do
    test "happy path returns list for CLI output" do
      input = %{
        metrics: %{
          triangle_count: 2,
          surface_area: 1.41420896253,
          bounding_box: [
            {1.0, 0.0, 0.0},
            {1.0, 0.0, 1.0},
            {0.0, 0.0, 0.0},
            {0.0, 0.0, 1.0},
            {1.0, 1.0, 0.0},
            {1.0, 1.0, 1.0},
            {0.0, 1.0, 0.0},
            {0.0, 1.0, 1.0}
          ]
        }
      }

      {:ok, output} = StlAnalyzer.View.Cli.build(input)

      expected = [
        "Number of Triangles: 2",
        "Surface Area: 1.4142",
        "Bounding Box: {x: 1.0, y: 0.0, z: 0.0}, {x: 1.0, y: 0.0, z: 1.0}, {x: 0.0, y: 0.0, z: 0.0}, {x: 0.0, y: 0.0, z: 1.0}, {x: 1.0, y: 1.0, z: 0.0}, {x: 1.0, y: 1.0, z: 1.0}, {x: 0.0, y: 1.0, z: 0.0}, {x: 0.0, y: 1.0, z: 1.0}"
      ]

      assert output == expected
    end
  end
end
