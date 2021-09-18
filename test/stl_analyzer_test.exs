defmodule StlAnalyzerTest do
  use ExUnit.Case
  doctest StlAnalyzer

  @example_file "models/simple_solid.stl"
  @bad_example_file "models/bad_simple_solid.stl"
  @duplicate_facet_simple_solid "models/dup_tri_simple_solid.stl"
  @large_file "models/StegosaurusPickHolder-Tortex-1.0mm.stl"

  test "happy path parse example file" do
    {:ok, example_file} = StlAnalyzer.File.fetch(@example_file)

    {:ok, solid} = StlAnalyzer.run(example_file)

    surface_area = 1.4142135623730951

    assert solid.name == "simple"

    [f0, f1] = solid.facets
    assert f0.surface_area == surface_area / 2
    assert f1.surface_area == surface_area / 2

    metrics = solid.metrics
    assert metrics.triangle_count == 2
    assert metrics.surface_area == surface_area
    refute metrics.bounding_box == []
  end

  @tag capture_log: true
  test "error path parse invalid file" do
    {:ok, example_file} = StlAnalyzer.File.fetch(@duplicate_facet_simple_solid)

    error = {:error, "file structure is invalid"}
    assert error == StlAnalyzer.run(example_file)
  end

  test "happy path parse large file" do
    {:ok, file} = StlAnalyzer.File.fetch(@large_file)

    {:ok, solid} = StlAnalyzer.run(file)

    surface_area = 16934.070758016467

    assert solid.name == "OpenSCAD_Model"

    metrics = solid.metrics
    assert metrics.triangle_count == 1526
    assert metrics.surface_area == surface_area
    refute metrics.bounding_box == []
  end

  @tag capture_log: true
  test "error path lex bad example file" do
    {:ok, example_file} = StlAnalyzer.File.fetch(@bad_example_file)

    {code, response} = StlAnalyzer.run(example_file)

    assert code == :error
    assert response == "{1, :stl_lexer, {:illegal, 'solid \\n'}}"
  end
end
