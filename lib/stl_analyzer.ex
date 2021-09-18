defmodule StlAnalyzer do
  require Logger

  @invalid_file_structure "file structure is invalid"

  @moduledoc """
  Documentation for StlAnalyzer.
  """

  @doc """

  ## Examples

      iex> {:ok, file} = StlAnalyzer.File.fetch("models/simple_solid.stl")
      iex> StlAnalyzer.run(file)
      {:ok, %StlAnalyzer.Solid{metadata: %{}, facets: [%StlAnalyzer.Facet{normal: {0.0, 0.0, 0.0}, surface_area: 0.7071067811865476, vertices: [{1.0, 1.0, 1.0}, {0.0, 1.0, 1.0}, {0.0, 0.0, 0.0}]}, %StlAnalyzer.Facet{normal: {0.0, 0.0, 0.0}, surface_area: 0.7071067811865476, vertices: [{1.0, 1.0, 1.0}, {1.0, 0.0, 0.0}, {0.0, 0.0, 0.0}]}], metrics: %{bounding_box: [{1.0, 0.0, 0.0}, {1.0, 0.0, 1.0}, {0.0, 0.0, 0.0}, {0.0, 0.0, 1.0}, {1.0, 1.0, 0.0}, {1.0, 1.0, 1.0}, {0.0, 1.0, 0.0}, {0.0, 1.0, 1.0}], surface_area: 1.4142135623730951, triangle_count: 2, lower_bounds: {0.0, 0.0, 0.0}, upper_bounds: {1.0, 1.0, 1.0}}, name: "simple"}}

  """

  @spec run(String.t()) :: {:ok, StlAnalyzer.Solid.t()} | {:error, String.t()}
  def run(file) do
    with {:ok, tokens, _} <- :stl_lexer.string(to_charlist(file)),
         {:ok, solid} <- StlAnalyzer.Parser.parse(tokens) do
      {:ok, %{solid | facets: Map.values(solid.facets)}}
    else
      {:error, reason, _other} ->
        msg = inspect(reason)
        :ok = Logger.error(msg, label: "Lexer Error")
        {:error, msg}

      {:error, :invalid} ->
        _ = Logger.warn(@invalid_file_structure)
        {:error, @invalid_file_structure}
    end
  end

  def stream(stream) do
    solid =
      stream
      |> Stream.flat_map(fn line ->
        {:ok, lex, _} = :stl_lexer.string(to_charlist(line))

        lex
      end)
      |> Stream.transform([%StlAnalyzer.Solid{}], fn x, acc ->
        StlAnalyzer.StreamParser.parse(x, acc)
      end)
      |> Enum.to_list()
      |> List.last()

    {:ok, solid}
  end

  def flow(stream) do
    try do
      StlAnalyzer.Counter.start_link()

      solid =
        stream
        |> Flow.from_enumerable()
        |> Flow.map(fn line ->
          :stl_lexer.string(to_charlist(line))
          |> StlAnalyzer.FlowParser.facet_counter()
          |> IO.inspect(label: "Lexer Line")
        end)
        # |> Flow.partition()
        |> Flow.reduce(fn -> [%StlAnalyzer.Solid{}] end, fn x, acc ->
          StlAnalyzer.FlowParser.parse(x, acc)
        end)
        |> Enum.to_list()
        |> List.last()

      {:ok, solid}
    after
      StlAnalyzer.Counter.clean_up()
    rescue
      error ->
        Logger.error(inspect(error))
        {:error, error}
    end
  end
end
