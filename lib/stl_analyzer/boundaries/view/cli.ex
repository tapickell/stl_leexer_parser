defmodule StlAnalyzer.View.Cli do
  def build(stl) do
    metrics = stl.metrics

    {:ok,
     [
       "Number of Triangles: " <> triangles(metrics.triangle_count),
       "Surface Area: " <> surface_area(metrics.surface_area),
       "Bounding Box: " <> bounding_box(metrics.bounding_box)
     ]}
  end

  defp bounding_box(list) do
    list
    |> Enum.map(fn {x, y, z} -> %{x: x, y: y, z: z} end)
    |> inspect()
    |> String.replace("[", "")
    |> String.replace("]", "")
    |> String.replace("%", "")
  end

  defp surface_area(sa), do: to_string(Float.round(sa, 4))

  defp triangles(tri), do: to_string(tri)
end
