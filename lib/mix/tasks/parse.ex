defmodule Mix.Tasks.Parse do
  use Mix.Task

  @impl Mix.Task
  def run([filename | _]) do
    with {:ok, file} <- StlAnalyzer.File.fetch(filename),
         {:ok, stl} <- StlAnalyzer.stream(file),
         {:ok, stl_view} <- StlAnalyzer.View.Cli.build(stl) do
      Enum.each(stl_view, fn line -> Mix.shell().info(line) end)
    else
      {:error, error} -> Mix.shell().error(error)
    end
  end
end
