use Mix.Config

config :logger,
  backends: [:console],
  level: :debug

config :murnau,
  ctrl_adapter: Murnau.Adapter.Telegram,
  ctrl_api: Murnau.Adapter.Telegram.Api,
  ctrl_port: 80,
  telegram_url: "https://api.testlegram.org",
  labor_adapter: Murnau.Adapter.Labor,
  labor_url: "https://freieslabor.org",
  labor_chat_id: -2,
  telegram_token: "1234",
  labor_user: "murnau",
  labor_token: "O",
  open_timeout: 1 * 60 * 1000
