defmodule StlAnalyzer.Solid do
  @type t :: %__MODULE__{}

  defstruct name: nil,
            facets: %{},
            metrics: %{
              triangle_count: 0,
              surface_area: 0.0,
              lower_bounds: {0.0, 0.0, 0.0},
              upper_bounds: {0.0, 0.0, 0.0},
              bounding_box: []
            },
            metadata: %{}
end
