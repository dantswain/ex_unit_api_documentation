defmodule ExUnitApiDocumentation.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_unit_api_documentation,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: ["lib", "web"],
     compilers: [:phoenix] ++ Mix.compilers,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:phoenix, :logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:phoenix, "~> 0.17.0"},
     {:phoenix_html, "~>2.1"},
     {:httpoison, git: "http://github.com/dantswain/httpoison", branch: "request_refactor"}]
  end
end
