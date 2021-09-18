defmodule StlAnalyzer.StreamParser do
  alias StlAnalyzer.{Calculations, Facet, Solid}

  @solid "solid "
  @name_empty ":name_empty"

  def parse(token, [solid] \\ [%StlAnalyzer.Solid{}]) do
    with {:ok, accum} <- parse_token(token, solid) do
      {[accum], [accum]}
    else
      {:end_solid, accum} -> {:halt, accum}
    end
  end

  def flow(token, solid \\ %StlAnalyzer.Solid{}) do
    with {:ok, accum} <- parse_token(token, solid) do
      accum
    else
      {:end_solid, accum} -> accum
    end
  end

  defp parse_token({:start_solid, _, match}, solid) do
    string = to_string(match)

    cond do
      String.length(string) > 6 ->
        @solid <> name = string
        {:ok, %{solid | name: name}}

      String.length(string) <= 6 ->
        {:ok, %{solid | name: @name_empty}}
    end
  end

  defp parse_token({:start_facet, _, match}, solid) do
    normal =
      match
      |> to_string()
      |> normal_points()

    {:ok, %{solid | facets: [%Facet{normal: normal} | solid.facets]}}
  end

  defp parse_token({:start_loop, _, _match}, solid) do
    {:ok, solid}
  end

  defp parse_token({:vertex, _, match}, solid) do
    vertex =
      match
      |> to_string()
      |> vertex_points()

    [current_facet | rest] = solid.facets
    current_facet = %{current_facet | vertices: [vertex | current_facet.vertices]}

    {:ok, %{solid | facets: [current_facet | rest]}}
  end

  defp parse_token({:end_loop, _, _match}, solid) do
    {:ok, solid}
  end

  defp parse_token({:end_facet, _, _match}, solid) do
    [current_facet | rest] = solid.facets
    [a, b, c] = current_facet.vertices
    surface_area = Calculations.surface_area(a, b, c)
    current_facet = %{current_facet | surface_area: surface_area}

    metrics = %{
      solid.metrics
      | surface_area: solid.metrics.surface_area + current_facet.surface_area,
        triangle_count: solid.metrics.triangle_count + 1,
        lower_bounds:
          Calculations.lower_bounds(
            solid.metrics.lower_bounds,
            Calculations.lower_bounds(current_facet.vertices)
          ),
        upper_bounds:
          Calculations.upper_bounds(
            solid.metrics.upper_bounds,
            Calculations.upper_bounds(current_facet.vertices)
          )
    }

    {:ok, %{solid | facets: [current_facet | rest], metrics: metrics}}
  end

  defp parse_token({:end_solid, _, _match}, solid) do
    metrics = %{
      solid.metrics
      | bounding_box:
          Calculations.bounding_box(
            solid.metrics.lower_bounds,
            solid.metrics.upper_bounds
          )
    }

    {:end_solid, %{solid | metrics: metrics}}
  end

  defp normal_points("facet normal " <> points) do
    points(points)
  end

  defp vertex_points("vertex " <> points) do
    points(points)
  end

  defp points(points) do
    empty_space = :binary.compile_pattern(" ")

    [x, y, z] =
      points
      |> String.split(empty_space)
      |> Enum.map(fn n ->
        {r, _} = Float.parse(n)
        r
      end)

    {x, y, z}
  end
end
