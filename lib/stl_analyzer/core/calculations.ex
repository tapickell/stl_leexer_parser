defmodule StlAnalyzer.Calculations do
  @type vertex() :: {float, float, float}
  @type bounding_box() :: [vertex(), ...]

  @spec surface_area(vertex(), vertex(), vertex()) :: float()
  def surface_area(v1, v2, v3) do
    v1v2 = vector(v1, v2)
    v1v3 = vector(v1, v3)

    orthogonal_vector(v1v2, v1v3)
    |> magnitude()
    |> triangle_area()
  end

  @spec bounding_box(vertex(), vertex()) :: bounding_box()
  def bounding_box({lx, ly, lz}, {ux, uy, uz}) do
    [
      {ux, ly, lz},
      {ux, ly, uz},
      {lx, ly, lz},
      {lx, ly, uz},
      {ux, uy, lz},
      {ux, uy, uz},
      {lx, uy, lz},
      {lx, uy, uz}
    ]
  end

  @spec lower_bounds(vertex(), vertex()) :: vertex()
  def lower_bounds({x1, y1, z1}, {x2, y2, z2}) do
    {min(x1, x2), min(y1, y2), min(z1, z2)}
  end

  @spec lower_bounds([vertex(), ...]) :: vertex()
  def lower_bounds([{x1, y1, z1}, {x2, y2, z2}, {x3, y3, z3}]) do
    {min(x1, min(x2, x3)), min(y1, min(y2, y3)), min(z1, min(z2, z3))}
  end

  @spec upper_bounds(vertex(), vertex()) :: vertex()
  def upper_bounds({x1, y1, z1}, {x2, y2, z2}) do
    {max(x1, x2), max(y1, y2), max(z1, z2)}
  end

  @spec upper_bounds([vertex(), ...]) :: vertex()
  def upper_bounds([{x1, y1, z1}, {x2, y2, z2}, {x3, y3, z3}]) do
    {max(x1, max(x2, x3)), max(y1, max(y2, y3)), max(z1, max(z2, z3))}
  end

  defp vector({x1, y1, z1}, {x2, y2, z2}) do
    {x2 - x1, y2 - y1, z2 - z1}
  end

  defp orthogonal_vector({x1, y1, z1}, {x2, y2, z2}) do
    cx = y1 * z2 - y2 * z1
    cy = x1 * z2 - x2 * z1
    cz = x1 * y2 - x2 * y1

    {cx, cy, cz}
  end

  defp magnitude({x, y, z}) do
    a = :math.pow(x, 2) + :math.pow(y, 2) + :math.pow(z, 2)

    a
    |> abs()
    |> :math.sqrt()
  end

  defp triangle_area(pgram_area), do: pgram_area / 2
end
