defmodule Murnau.Mixfile do
  use Mix.Project

  def project do
    [app: :murnau,
     version: "0.0.1",
     elixir: "~> 1.3.3",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     homepage_url: "https://github.com/freieslabor/murnau",
     source_url: "https://github.com/freieslabor/murnau",
     docs: [extras: ["README.md"]],
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test,
                         "coveralls.detail": :test,
                         "coveralls.post": :test,
                         "coveralls.html": :test],
     aliases: [test: "test --no-start"]
     ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    dev_apps = Mix.env == :dev && [:reprise] || []
    [applications: [:logger, :httpoison, :poison] ++ dev_apps,
     mod: {Murnau, []}]
  end

  defp elixirc_paths(:prod), do: ["lib"]
  defp elixirc_paths(_), do: ["test/server", "lib"]

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:httpoison, "~> 0.8.3"},
     {:reprise, "~> 0.5", only: :dev},
     {:credo, "~> 0.3", only: [:dev, :test]},
     {:dialyxir, "~> 0.3.5", only: [:dev, :test]},
     {:inch_ex, "~> 0.5.4", only: :docs},
     {:logger_file_backend, ">= 0.0.4"},
     {:exrm, "~> 1.0.0" },
     {:ex_doc, "~> 0.12", only: :dev},
     {:poison, "~> 3.0.0"},
     {:excoveralls, "~> 0.5.4", only: :test}]
  end
end
