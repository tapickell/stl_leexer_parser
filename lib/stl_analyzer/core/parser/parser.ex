defmodule StlAnalyzer.Parser do
  alias StlAnalyzer.{Calculations, Facet, Solid}

  def parse([h | rest]) do
    case parse(h, rest, %Solid{}) do
      {:error, any} -> {:error, any}
      parsed -> {:ok, parsed}
    end
  end

  defp parse({:start_solid, _, match}, [h | rest], solid) do
    "solid " <> name = to_string(match)
    parse(h, rest, %{solid | name: name})
  end

  defp parse({:start_facet, _, match}, [h | rest], solid) do
    normal =
      match
      |> to_string()
      |> normal_points()

    {facet, [h | rest]} = parse(h, rest, %Facet{normal: normal})

    case Map.has_key?(solid.facets, facet.vertices) do
      true ->
        {:error, :invalid}

      false ->
        metrics = %{
          solid.metrics
          | surface_area: solid.metrics.surface_area + facet.surface_area,
            triangle_count: solid.metrics.triangle_count + 1,
            lower_bounds:
              Calculations.lower_bounds(
                solid.metrics.lower_bounds,
                Calculations.lower_bounds(facet.vertices)
              ),
            upper_bounds:
              Calculations.upper_bounds(
                solid.metrics.upper_bounds,
                Calculations.upper_bounds(facet.vertices)
              )
        }

        parse(h, rest, %{
          solid
          | facets: Map.put(solid.facets, facet.vertices, facet),
            metrics: metrics
        })
    end
  end

  defp parse({:start_loop, _, _match}, [h | rest], facet) do
    parse(h, rest, facet)
  end

  defp parse({:vertex, _, match}, [h | rest], facet) do
    vertex =
      match
      |> to_string()
      |> vertex_points()

    parse(h, rest, %{facet | vertices: [vertex | facet.vertices]})
  end

  defp parse({:end_loop, _, _match}, [h | rest], facet) do
    parse(h, rest, facet)
  end

  defp parse({:end_facet, _, _match}, tokens, facet) do
    [a, b, c] = facet.vertices
    surface_area = Calculations.surface_area(a, b, c)
    {%{facet | surface_area: surface_area}, tokens}
  end

  defp parse({:end_solid, _, _match}, [], solid) do
    metrics = %{
      solid.metrics
      | bounding_box:
          Calculations.bounding_box(
            solid.metrics.lower_bounds,
            solid.metrics.upper_bounds
          )
    }

    %{solid | metrics: metrics}
  end

  defp normal_points("facet normal " <> points) do
    points(points)
  end

  defp vertex_points("vertex " <> points) do
    points(points)
  end

  defp points(points) do
    [x, y, z] =
      points
      |> String.split(" ")
      |> Enum.map(fn n ->
        {r, _} = Float.parse(n)
        r
      end)

    {x, y, z}
  end
end
