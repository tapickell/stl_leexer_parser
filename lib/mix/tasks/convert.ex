defmodule Mix.Tasks.Convert do
  use Mix.Task

  @impl Mix.Task

  @ascii "-ascii"
  @binary "-binary"
  @ascii_pattern ["ascii", @ascii]
  @binary_pattern ["binary", @binary]

  def run([filename | _]) do
    with {:ok, file} <- StlAnalyzer.File.fetch(filename),
         {:ok, converted, new_type} <- StlAnalyzer.Converter.run(file),
         :ok <- StlAnalyzer.File.store(filename(filename, new_type), converted) do
      Enum.each(converted, fn line -> Mix.shell().info(line) end)
    else
      {:error, error} -> Mix.shell().error(error)
    end
  end

  defp filename(filename, new_type) do
    ext = Path.extname(filename)

    filename
    |> String.replace(opposite_pattern(new_type), "")
    |> String.replace(ext, type(new_type) <> ext)
  end

  defp opposite_pattern(:ascii) do
    :binary.compile_pattern(@binary_pattern)
  end

  defp opposite_pattern(:binary) do
    :binary.compile_pattern(@ascii_pattern)
  end

  defp type(:ascii), do: @ascii
  defp type(:binary), do: @binary
end
