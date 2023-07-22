defmodule Terrible.Accounting.AccountTypeTest do
  use Terrible.DataCase

  alias Terrible.Accounting
  alias Terrible.Accounting.AccountType

  describe "create" do
    test "creates an account type" do
      attrs = %{
        name: "Cash",
        type: :asset
      }

      {:ok, account_type} =
        AccountType
        |> Ash.Changeset.for_create(:create, attrs)
        |> Accounting.create()

      assert account_type.id
      assert account_type.name == "Cash"
      assert account_type.type == :asset
    end
  end
end
