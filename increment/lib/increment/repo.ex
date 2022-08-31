defmodule Increment.Repo do
  use Ecto.Repo,
    otp_app: :increment,
    adapter: Ecto.Adapters.Postgres
end
