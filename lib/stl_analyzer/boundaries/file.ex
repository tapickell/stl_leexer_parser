defmodule StlAnalyzer.File do
  def fetch(filename) do
    File.read(filename)
  end

  def store(filename, data) do
    File.write(filename, data)
  end
end
