use Mix.Config

config :murnau,
  ctrl_api: Murnau.Adapter.Telegram,
  ctrl_port: 4000,
  telegram_url: "http://localhost:4000",
  telegram_token: "12345",
  labor_chat_id: -2

config :murnau, Murnau.Adapter.Telegram,
  languages: "ger"
