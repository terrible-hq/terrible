# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Terrible.Repo.insert!(%Terrible.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

account_type_attrs = [
  %{
    name: "Cash",
    type: :asset
  },
  %{
    name: "Savings",
    type: :asset
  },
  %{
    name: "Checking",
    type: :asset
  },
  %{
    name: "Credit Card",
    type: :liability
  },
  %{
    name: "Line of Credit",
    type: :liability
  }
]

Enum.each(account_type_attrs, fn attrs ->
  Terrible.Accounting.AccountType
  |> Ash.Changeset.for_create(:create, attrs)
  |> Terrible.Accounting.create!()
end)
