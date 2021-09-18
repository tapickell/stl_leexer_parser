defmodule StlAnalyzer.MixProject do
  use Mix.Project

  def project do
    [
      app: :stl_analyzer,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      dialyzer: [
        plt_add_deps: :transitive,
        plt_add_apps: [:mix, :ex_unit],
        flags: [
          :unmatched_returns,
          :error_handling,
          :race_conditions,
          :no_opaque
        ]
      ],
      test_coverage: [tool: ExCoveralls],
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {StlAnalyzer.Application, []}
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.0", only: :dev},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:flow, "~> 0.14"}
    ]
  end
end
