defmodule StlAnalyzer.ParserTest do
  use ExUnit.Case

  describe "parse/1" do
    test "happy path with lexed data from exmaple file" do
      {:ok, parsed} = StlAnalyzer.Parser.parse(lexed_data())

      refute parsed.facets == []
    end
  end

  defp lexed_data do
    [
      {:start_solid, 1, 'solid simple'},
      {:start_facet, 2, 'facet normal 0 0 0'},
      {:start_loop, 3, 'outer loop'},
      {:vertex, 4, 'vertex 0 0 0'},
      {:vertex, 5, 'vertex 1 0 0'},
      {:vertex, 6, 'vertex 1 1 1'},
      {:end_loop, 7, 'endloop'},
      {:end_facet, 8, 'endfacet'},
      {:start_facet, 9, 'facet normal 0 0 0'},
      {:start_loop, 10, 'outer loop'},
      {:vertex, 11, 'vertex 0 0 0'},
      {:vertex, 12, 'vertex 0 1 1'},
      {:vertex, 13, 'vertex 1 1 1'},
      {:end_loop, 14, 'endloop'},
      {:end_facet, 15, 'endfacet'},
      {:end_solid, 16, 'endsolid simple'}
    ]
  end
end
