# StlAnalyzer

**Parse ASCII STL files and analyze the solid model**

## Usage

```
± mix parse models/simple_solid.stl
Number of Triangles: 2
Surface Area: 1.4142
Bounding Box: {x: 1.0, y: 0.0, z: 0.0}, {x: 1.0, y: 0.0, z: 1.0}, {x: 0.0, y: 0.0, z: 0.0}, {x: 0.0, y: 0.0, z: 1.0}, {x: 1.0, y: 1.0, z: 0.0}, {x: 1.0, y: 1.0, z: 1.0}, {x: 0.0, y: 1.0, z: 0.0}, {x: 0.0, y: 1.0, z: 1.0}
```

## Notes

“Give me six hours to chop down a tree and I will spend the first four sharpening the axe.”
― Abraham Lincoln

I started this project with 1 1/2 days of analyzing the problem, taking notes, researching the calculations needed and de-comping work into a TODO list to work from. I wanted to ensure I understood the problems and the domain in which I was working in well enough to write code that is more declarative and easy to understand. I also wanted to make sure that I addressed any outstanding questions I had about the requirements before starting the first line of code. After researching the calculations required and the stl ascii file format more, including looking at example files in the wild, I felt I had a good understanding of the requirements of the application and was confident in the design ideas I was starting with.

Overall, I thought about this application as one data flow:

1) Get file data incoming from a handler
2) Parse into data structures
3) Run calculations returning updated version of data structure
4) Pass resulting data structure through view layer

For the project I wanted to use a layered architecture similar to a pattern I have applied in the past called the HAQT pattern. This pattern worked well for me within OOP languages like Ruby in the context of a restful application. I found that for Elixir's style for solving problems this was not a direct fit. The layering is what I wanted, but the ideas to separate contexts by did not apply well to this application.

I found that the ideas from the book, Designing Elixir Systems with OTP by James Edward Gray, II and Bruce A. Tate, to be a better take on a layered design applied to an Elixir application. It is what the HAQT pattern should be in the context of a FP language. I utilized the concepts of a Data Layer (data structures), a Functional Core (the business logic), Boundaries (the API layers), and Testing (testing from the outside in, performance tests and also some typespecs).

This was enough to get the problem solved. As next steps, I would have added Lifecycles (Supervision tree layer to manage workers), and Workers (supervised workers to do calculations and parsing within). I am only leveraging a single application supervisor at this point and I am doing most the actual work from the parser using the calculations module. This could be better with supervised workers.

I did not want to start with optimizing the way the files are analyzed until I had the ability to benchmark the fully working program with an array of different model sizes. Anything I would have done to optimize before reaching this stage of the project would have been done without any proof of improvements needed or actual improvements obtained.

One of the things I wanted to ensure was that I was not iterating over
file contents multiple times to get the transformation from raw ascii file data
to a data structure with analysis metrics. It is iterated over by the Lexer and then once more
by the Parser that also triggers the calculations to get the metric data required. I think this approach leans toward the speed side of things but can be memory heavy given large files.

In testing, this seems to be fine for the average files I could find on Thingiverse.
But for the one large example file I found with over 3 million facets, the speed
averages around 3 minutes from the mix run task but the memory usage for loading
that large of a file might be unacceptable. On a 32GB system, it maxed
the ram for about 15 seconds during the lexing process, and for about 30 seconds during the parsing process. The Beam VM handled it well and the program did not crash, but it felt less than ideal.

Since my experience with Elixir applications comes from a web service point of view, I have an expectation of faster response times. This application is handling a different kind of problem. Maybe running a large ram instance and having analysis times be anything under 5 seconds for large files is perfectly acceptable. I am unsure what the SLA's and expectations for this type of work should be.

If the real world use is for many files of 1 million facets and higher, then a different approach may be better which would probably be a little slower to run but not as memory intensive. I think that kind of approach would split the work up into batches or streams instead of parsing and analyzing the file in one go. By batching out parts of it to workers and separating the parsing from the metric calculation, the memory footprint can be managed easier. This would be tunable depending on how much of the file we want to lex, parse, and calculate at one time.

This brings an extra layer of complexity with it, though. If I were to batch out the work to reduce memory footprint on large file analysis, then I need to come up with a way to reduce all that data into the data structure when all the batches are complete, then finish the final calculations that can only be done after the entire file is parsed out.

I tried the lexing and parsing with leex and yecc, more than anything because they are available within Erlang with no external dependencies. After a bit of a learning curve I found leex was enough to get the lexing done but yecc was not as flexible as I wanted for the parsing so I wrote my own parser. I used recursion to parse through the tokens from the lexer, which tends to being memory heavy when working through the large files. I looked at some other projects including the Elixir language itself and Absinthe. For the Elixir language they use their own lexer and make use of yecc for the parsing. Absinthe used to make use of leex and yecc but has switched to using Nimble Parsec which I believe not only gives them more flexibility but also some performance improvements. I would like to try switching to Nimble Parsec to gain some performance for the parsing section.

## Summary

I really enjoyed working on this problem. This has been a challenging and intriguing problem to solve. Given more time I would like to try to optimize the parsing and calculation parts to be faster and less memory intensive.
It all really depends on what the real world file sizes are and how often we need to run 1million+ facet models. It also depends on what our SLA's are to our users, whether we want to be faster or run cheaper instances. Everything in software is a trade off.


## Performance Benchmarking

```
# ± mix run test/benchmark/small_to_large_files.exs
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

# File Size   Model       Number of Triangles
# 785M        I-am-groot            3_295_832
#  27M        fractal                 179_460
# 7.8M        OpenSCAD_Model           43_710
# 292K        OpenSCAD_Model            1_526
# 4.0K        simple                        2
```

## Test Coverage

```
± MIX_ENV=test mix coveralls.html
..........

Finished in 0.1 seconds
1 doctest, 9 tests, 0 failures

Randomized with seed 22422
----------------
COV    FILE                                        LINES RELEVANT   MISSED
0.0% lib/mix/tasks/parse.ex                         14        5        5
100.0% lib/stl_analyzer.ex                            30        4        0
100.0% lib/stl_analyzer/application.ex                19        3        0
100.0% lib/stl_analyzer/boundaries/file.ex             5        1        0
100.0% lib/stl_analyzer/boundaries/view/cli.ex        25        8        0
100.0% lib/stl_analyzer/core/calculations.ex          70       15        0
100.0% lib/stl_analyzer/core/parser.ex                95       32        0
0.0% lib/stl_analyzer/data/facet.ex                  5        0        0
0.0% lib/stl_analyzer/data/solid.ex                 14        0        0
32.4% src/stl_lexer.erl                            1158      518      350
[TOTAL]  39.4%
----------------
Generating report...
Saved to: cover/
```

## Dialyzer

```
± mix dialyzer
Compiling 1 file (.ex)
Finding suitable PLTs
Checking PLT...
[:benchee, :compiler, :deep_merge, :dialyxir, :elixir, :erlex, :ex_unit, :kernel, :logger, :mix, :stdlib]
PLT is up to date!
No :ignore_warnings opt specified in mix.exs and default does not exist.

Starting Dialyzer
[
check_plt: false,
init_plt: '/home/todd/code/_test/stl_parser/_build/dev/dialyxir_erlang-22.0.7_elixir-1.9.1_deps-dev.plt',
files: ['/home/todd/code/_test/stl_parser/_build/dev/lib/stl_analyzer/ebin/Elixir.Mix.Tasks.Parse.beam',
'/home/todd/code/_test/stl_parser/_build/dev/lib/stl_analyzer/ebin/Elixir.StlAnalyzer.Application.beam',
'/home/todd/code/_test/stl_parser/_build/dev/lib/stl_analyzer/ebin/Elixir.StlAnalyzer.Calculations.beam',
'/home/todd/code/_test/stl_parser/_build/dev/lib/stl_analyzer/ebin/Elixir.StlAnalyzer.Facet.beam',
'/home/todd/code/_test/stl_parser/_build/dev/lib/stl_analyzer/ebin/Elixir.StlAnalyzer.File.beam',
...],
warnings: [:unmatched_returns, :error_handling, :race_conditions, :no_opaque,
...]
]
Total errors: 0, Skipped: 0, Unnecessary Skips: 0
done in 0m1.82s
done (passed successfully)
```
