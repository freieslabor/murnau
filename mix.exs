defmodule Murnau.Mixfile do
  use Mix.Project

  def project do
    [app: :murnau,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    dev_apps = Mix.env == :dev && [:reprise] || []
    [applications: [:logger] ++ dev_apps,
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
    [{:reprise, "~> 0.5", only: :dev}]
  end
end
