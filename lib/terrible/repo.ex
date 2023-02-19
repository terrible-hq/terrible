defmodule Terrible.Repo do
  use AshPostgres.Repo,
    otp_app: :terrible,
    adapter: Ecto.Adapters.Postgres

  def installed_extensions do
    ["uuid-ossp", "citext"]
  end
end
