defmodule StlAnalyzer.FlowParser do
  alias StlAnalyzer.{Calculations, Facet, Solid}

  require Logger

  @solid "solid "
  @name_empty ":name_empty"

  def parse(token, [solid] \\ [%StlAnalyzer.Solid{}]) do
    [parse_token(token, solid)]
  end

  def facet_counter({:ok, [{:start_facet, _, line}], _}) do
    index = StlAnalyzer.Counter.increment()
    {:start_facet, %{facet: index}, line}
  end

  def facet_counter({:ok, [{:vertex, _, line}], _}) do
    index = StlAnalyzer.Counter.lookup()
    {:vertex, %{facet: index}, line}
  end

  def facet_counter({:ok, [{:end_facet, _, line}], _}) do
    index = StlAnalyzer.Counter.lookup()
    {:end_facet, %{facet: index}, line}
  end

  def facet_counter({:ok, [{:end_solid, _, line}], _}) do
    index = StlAnalyzer.Counter.lookup()
    {:end_solid, %{facet: index}, line}
  end

  def facet_counter({:ok, [lexed], _}), do: lexed

  defp parse_token({:start_solid, _, match}, solid) do
    string = to_string(match)

    cond do
      String.length(string) > 6 ->
        @solid <> name = string
        %{solid | name: name}

      String.length(string) <= 6 ->
        %{solid | name: @name_empty}
    end
  end

  defp parse_token({:start_facet, %{facet: index}, match}, solid) do
    normal =
      match
      |> to_string()
      |> normal_points()

    facets = List.insert_at(solid.facets, index, %StlAnalyzer.Facet{normal: normal})
    %{solid | facets: facets}
  end

  defp parse_token({:start_loop, _, _match}, solid), do: solid

  defp parse_token({:vertex, %{facet: index}, match}, solid) do
    vertex =
      match
      |> to_string()
      |> vertex_points()

    facets =
      List.update_at(solid.facets, index, fn facet ->
        facet |> IO.inspect(label: "Facet: #{index}, pre vertex update")

        %{facet | vertices: [vertex | facet.vertices]}
        |> IO.inspect(label: "Updated Facet: #{index} w/ vertex: #{inspect(vertex)}")
      end)

    %{solid | facets: facets}
  end

  defp parse_token({:end_loop, _, _match}, solid), do: solid

  defp parse_token({:end_facet, %{facet: index}, _match}, solid) do
    Logger.warn("END FACET INDEX: #{index}, SOLID FACETS: #{length(solid.facets)}")

    {:ok, facet} = Enum.fetch(solid.facets, index)
    %{vertices: facet_vertices} = facet

    # Logger.warn("INDEX: #{index} CURRENT_FACET: #{inspect(current_facet)}")

    [a, b, c] = facet_vertices
    surface_area = Calculations.surface_area(a, b, c)

    metrics = %{
      solid.metrics
      | surface_area: solid.metrics.surface_area + surface_area,
        lower_bounds:
          Calculations.lower_bounds(
            solid.metrics.lower_bounds,
            Calculations.lower_bounds(facet_vertices)
          ),
        upper_bounds:
          Calculations.upper_bounds(
            solid.metrics.upper_bounds,
            Calculations.upper_bounds(facet_vertices)
          )
    }

    facets =
      List.update_at(solid.facets, index, fn facet ->
        %{facet | surface_area: surface_area}
      end)

    %{solid | facets: facets, metrics: metrics}
  end

  defp parse_token({:end_solid, %{facet: index}, _match}, solid) do
    metrics = %{
      solid.metrics
      | triangle_count: index + 1,
        bounding_box:
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
