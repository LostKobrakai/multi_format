defmodule MultiFormat.MixProject do
  use Mix.Project

  def project do
    [
      name: "MultiFormat",
      app: :multi_format,
      version: "0.1.0",
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
      {:ex_doc, "~> 0.18.3"}
    ]
  end

  defp description() do
    "MultiFormat is a helper for Phoenix.Router when working with multi format 
    routes."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "MultiFormat",
      # These are the default files included in the package
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Benjamin Milde", "José Valim"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/LostKobrakai/multi_format"}
    ]
  end
end
