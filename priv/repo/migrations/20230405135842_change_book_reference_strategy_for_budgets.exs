defmodule Terrible.Repo.Migrations.ChangeBookReferenceStrategyForBudgets do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop constraint(:budgets, "budgets_book_id_fkey")

    alter table(:budgets) do
      modify :book_id,
             references(:books,
               column: :id,
               prefix: "public",
               name: "budgets_book_id_fkey",
               type: :uuid,
               on_delete: :delete_all
             )
    end
  end

  def down do
    drop constraint(:budgets, "budgets_book_id_fkey")

    alter table(:budgets) do
      modify :book_id,
             references(:books,
               column: :id,
               prefix: "public",
               name: "budgets_book_id_fkey",
               type: :uuid
             )
    end
  end
end
