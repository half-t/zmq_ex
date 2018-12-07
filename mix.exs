defmodule ZmqEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :zmq_ex,
      version: "0.0.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      aliases: aliases(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp aliases do
    [
      compile: ["compile --warnings-as-errors"],
      test: ["format --check-formatted", "credo --strict", "test"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:junit_formatter, "~> 2.2", only: [:test]},
      {:excoveralls, "~> 0.10", only: :test},
      {:credo, "~> 1.0.0-rc1", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:ex_ct, "~> 0.0.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description do
    "Elixir ZeroMQ implementation"
  end

  defp package() do
    [
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/half-t/zmq_ex"},
      maintainers: []
    ]
  end
end
