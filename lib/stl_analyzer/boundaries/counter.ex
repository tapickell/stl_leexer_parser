defmodule StlAnalyzer.Counter do
  def start_link() do
    :ets.new(:counter, [{:write_concurrency, true}, :named_table, :public])
  end

  def clean_up() do
    :ets.delete(:counter)
  end

  def increment() do
    :ets.update_counter(:counter, :count, {2, 1}, {:count, -1})
  end

  def lookup() do
    case :ets.lookup(:counter, :count) do
      [count: index] -> index
      [] -> 0
    end
  end
end
