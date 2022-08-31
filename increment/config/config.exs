# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :increment,
  ecto_repos: [Increment.Repo]

# Configures the endpoint
config :increment, IncrementWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: IncrementWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Increment.PubSub,
  live_view: [signing_salt: "mPogB+5S"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
