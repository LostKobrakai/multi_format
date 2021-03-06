defmodule MultiFormat.MixProject do
  use Mix.Project

  def project do
    [
      name: "MultiFormat",
      app: :multi_format,
      version: "0.1.2",
      elixir: "~> 1.4",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      source_url: "https://github.com/LostKobrakai/multi_format"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.0"},
      {:ex_doc, "~> 0.18.3", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "MultiFormat is a helper for Phoenix.Router when working with multi format 
    routes."
  end

  defp package() do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Benjamin Milde"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/LostKobrakai/multi_format"}
    ]
  end
end
