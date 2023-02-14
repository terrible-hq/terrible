defmodule Terrible.Repo do
  use AshPostgres.Repo,
    otp_app: :terrible,
    adapter: Ecto.Adapters.Postgres
end
