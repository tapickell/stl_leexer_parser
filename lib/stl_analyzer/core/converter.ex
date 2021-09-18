defmodule StlAnalyzer.Converter do
  @eighty_zeros 1..80 |> Enum.map(fn _ -> <<0>> end) |> List.to_string()
  @new_line "\n"
  @spc " "
  @indent [@spc, @spc]
  @solid "solid"
  @facet "facet"
  @start_facet [@indent, @facet, @spc, "normal"]
  @loop "loop"
  @start_loop [@indent, @indent, "outer", @spc, @loop, @new_line]
  @vertex [@indent, @indent, @indent, "vertex"]
  @end_loop [@indent, @indent, "end", @loop, @new_line]
  @end_facet [@indent, "end", @facet, @new_line]
  @end_solid ["end", @solid]

  def run(file_data) when binary_part(file_data, 0, 5) == @solid do
    {:ok, @eighty_zeros, :binary}
  end

  # def run(file_data) when binary_part(file_data, 0, 80) == @eighty_zeros do
  def run(file_data) do
    io_list =
      file_data
      |> build_ascii()

    {:ok, io_list, :ascii}
  end

  def run(_file_data) do
    {:error, "Invalid File Format"}
  end

  defp build_ascii(<<_header::binary-size(80), tri_count::little-32, data::bitstring>>) do
    head = [@solid, @spc, @new_line]
    tail = [@end_solid, @spc, @new_line]

    {facets, _accum} =
      1..tri_count
      |> Enum.reduce({[], data}, fn _, {facets, data} ->
        {facet_data, rest} = facet(data)
        {[facet_data | facets], rest}
      end)

    [head | [Enum.reverse(facets) | tail]]
  end

  defp facet(
         <<normal::binary-size(12), a::binary-size(12), b::binary-size(12), c::binary-size(12),
           _::binary-size(2), rest::binary>>
       ) do
    normal_line = [@start_facet | [vertices(normal) | @new_line]]
    abc_lines = Enum.map([a, b, c], fn v -> [@vertex | [vertices(v) | @new_line]] end)

    {[normal_line | [@start_loop | [abc_lines | [@end_loop | @end_facet]]]], rest}
  end

  defp vertices(<<x::float-32, y::float-32, z::float-32>>) do
    [@spc, to_string(x), @spc, to_string(y), @spc, to_string(z)]
  end
end
