defmodule Murnau.Mixfile do
  use Mix.Project

  def project do
    [app: :murnau,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test,
                         "coveralls.detail": :test,
                         "coveralls.post": :test,
                         "coveralls.html": :test],
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
    [{:httpoison, "~> 0.8.0"},
     {:reprise, "~> 0.5", only: :dev},
     {:credo, "~> 0.3", only: [:dev, :test]},
     {:inch_ex, only: :docs},
     {:exrm, "~> 1.0.0" },
     {:poison, "~> 2.1.0"},
     {:excoveralls, "~> 0.5", only: :test},
     {:cowboy, "~> 1.0.0", only: :test},
     {:plug, "~> 1.0", only: :test},]
  end
end
