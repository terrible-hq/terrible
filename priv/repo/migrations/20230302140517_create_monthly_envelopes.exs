defmodule Terrible.Repo.Migrations.CreateMonthlyEnvelopes do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:monthly_envelopes, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("uuid_generate_v4()"), primary_key: true

      add :budget_id,
          references(:budgets,
            column: :id,
            name: "monthly_envelopes_budget_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :envelope_id,
          references(:envelopes,
            column: :id,
            name: "monthly_envelopes_envelope_id_fkey",
            type: :uuid,
            prefix: "public"
          ),
          null: false

      add :assigned_cents, :bigint, default: 0
      add :inserted_at, :utc_datetime_usec, null: false, default: fragment("now()")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("now()")
    end

    create unique_index(:monthly_envelopes, [:budget_id, :envelope_id],
             name: "monthly_envelopes_unique_monthly_envelope_index"
           )
  end

  def down do
    drop_if_exists unique_index(:monthly_envelopes, [:budget_id, :envelope_id],
                     name: "monthly_envelopes_unique_monthly_envelope_index"
                   )

    drop constraint(:monthly_envelopes, "monthly_envelopes_envelope_id_fkey")

    drop constraint(:monthly_envelopes, "monthly_envelopes_budget_id_fkey")

    drop table(:monthly_envelopes)
  end
end
