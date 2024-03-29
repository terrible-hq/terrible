defmodule Terrible.Repo.Migrations.AddTypeAndBookIdToEnvelopes do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:envelopes) do
      add :type, :text, default: "standard"

      add :book_id,
          references(:books,
            column: :id,
            name: "envelopes_book_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          null: false
    end

    create index(:envelopes, ["book_id", "type"], unique: true, where: "type = 'unassigned'")
  end

  def down do
    drop constraint(:envelopes, "envelopes_book_id_fkey")

    drop_if_exists index(:envelopes, ["book_id", "type"], name: "envelopes_book_id_type_index")

    alter table(:envelopes) do
      remove :book_id
      remove :type
    end
  end
end
