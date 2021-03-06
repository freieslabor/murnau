use Mix.Config

config :logger,
  backends: [{LoggerFileBackend, :logfile}]

config :logger, :logfile,
  path: "logs/murnau.log",
  level: :debug

config :murnau,
  ctrl_adapter: Murnau.Adapter.Telegram,
  ctrl_api: Murnau.Adapter.Telegram.Api,
  ctrl_port: 80,
  telegram_url: "https://api.telegram.org",
  labor_adapter: Murnau.Adapter.Labor,
  labor_url: "https://freieslabor.org",
  labor_cam_url: "http://webcam.freieslabor.org/current.jpg",
  open_timeout: 60 * 8,
  wait_timeout: 10,
  retry_timeout: 60 * 4

import_config "prod.secret.exs"
