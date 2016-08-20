use Mix.Config

config :logger,
  backends: [{LoggerFileBackend, :logfile}]

config :logger, :logfile,
  path: "logs/murnau.log",
  level: :debug

config :murnau,
  ctrl_adapter: Murnau.Adapter.Telegram,
  ctrl_api: Murnau.Adapter.Telegram.Api,
  ctrl_port: 4000,
  telegram_url: "https://api.testlegram.org",
  telegram_token: "1234",
  labor_chat_id: -2,
  labor_adapter: Murnau.Adapter.Labor,
  labor_url: "https://freiestestlabor.org",
  labor_cam_url: "http://webcam.freieslabor.org/current.jpg",
  open_timeout: 1 * 60 * 1000

config :murnau, Murnau.Adapter.Telegram,
  languages: "ger"
