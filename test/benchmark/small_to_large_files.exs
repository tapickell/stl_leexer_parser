:observer.start()

Benchee.run(
  %{
    "initial implementation" => fn input ->
      {:ok, example_file} = StlAnalyzer.File.fetch("models/" <> input)
      {:ok, solid} = StlAnalyzer.run(example_file)

      IO.inspect(solid.metrics.triangle_count, label: solid.name)
    end,
    "flow implementation" => fn input ->
      {:ok, solid} =
        File.stream!("models/" <> input)
        |> StlAnalyzer.flow()

      IO.inspect(solid.metrics.triangle_count, label: solid.name)
    end,
    "streaming implementation" => fn input ->
      {:ok, solid} =
        File.stream!("models/" <> input)
        |> StlAnalyzer.stream()

      IO.inspect(solid.metrics.triangle_count, label: solid.name)
    end
  },
  inputs: %{
    # "785M" => "groot_body_high_detail-ascii.stl",
    # "27M" => "affine_spiral.stl",
    # "7.8M" => "DalekBig.stl"
    "292K" => "StegosaurusPickHolder-Tortex-1.0mm.stl",
    "4.0K" => "simple_solid.stl"
  },
  time: 3,
  memory_time: 2
)

# -rw-r--r-- 1 todd todd 785M Nov 17 21:08 groot_body_high_detail-ascii.stl
# -rw-r--r-- 1 todd todd  27M Nov 17 21:06 affine_spiral.stl
# -rw-r--r-- 1 todd todd 7.8M Nov 17 19:07 DalekBig.stl
# -rw-r--r-- 1 todd todd 292K Nov 16 14:02 StegosaurusPickHolder-Tortex-1.0mm.stl
# -rw-r--r-- 1 todd todd  293 Nov 17 14:43 simple_solid.stl
#
# ± mix run test/benchmark/small_to_large_files.exs                                                                                                                                                           [4h] ✹ ✭
# Operating System: Linux
# CPU Information: Intel(R) Core(TM) i7-7600U CPU @ 2.80GHz
# Number of Available Cores: 4
# Available memory: 30.89 GB
# Elixir 1.9.1
# Erlang 22.0.7

# Benchmark suite executing with the following configuration:
# warmup: 2 s
# time: 30 s
# memory time: 0 ns
# parallel: 1
# inputs: 785M
# Estimated total run time: 32 s

# Benchmarking initial implementation with input 785M...
# I-am-groot : 3295832
# I-am-groot : 3295832

###### With input 785M #####
# Name                             ips        average  deviation         median         99th %
# initial implementation       0.00461       3.62 min     ±0.00%       3.62 min       3.62 min
#
##### With input 12M #####
# Name                             ips        average  deviation         median         99th %
# initial implementation          0.36         2.79 s     ±1.07%         2.79 s         2.85 s

###### With input 27M #####
# Name                             ips        average  deviation         median         99th %
# initial implementation         0.130         7.67 s     ±3.42%         7.77 s         7.86 s

###### With input 292K #####
# Name                             ips        average  deviation         median         99th %
# initial implementation         22.66       44.13 ms     ±7.58%       44.68 ms       54.09 ms

###### With input 4.0K #####
# Name                             ips        average  deviation         median         99th %
# initial implementation       13.34 K       74.96 μs    ±68.50%       64.74 μs      297.51 μs

###### With input 7.8M #####
# Name                             ips        average  deviation         median         99th %
# initial implementation          0.57         1.77 s     ±1.40%         1.76 s         1.81 s
