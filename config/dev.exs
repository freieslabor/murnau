use Mix.Config

config :logger,
  backends: [:console],
  level: :debug

config :murnau,
  ctrl_adapter: Murnau.Adapter.Telegram,
  ctrl_api: Murnau.Adapter.Telegram.Api,
  ctrl_port: 80,
  telegram_url: "https://api.telegram.org",
  labor_adapter: Murnau.Adapter.Labor.Api,
  labor_url: "https://freieslabor.org",
  open_timeout: 2,
  wait_timeout: 1,
  retry_timeout: 2

import_config "prod.secret.exs"
