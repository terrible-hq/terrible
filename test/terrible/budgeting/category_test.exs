defmodule Terrible.Budgeting.CategoryTest do
  use Terrible.DataCase

  alias Terrible.Budgeting.Category

  describe "System Category" do
    setup do
      book = book_fixture()
      category = category_fixture(%{book_id: book.id, type: :system})

      %{
        book: book,
        category: category
      }
    end

    test "create/2 with existing system category fails to create another system category", %{
      book: book
    } do
      assert {:error, invalid} =
               Category.create(%{name: "Another System", book_id: book.id, type: :system})

      error = invalid.errors |> Enum.at(0)
      assert error.message == "has already been taken"
    end

    test "list_by_book_id/1 returns only standard categories", %{book: book, category: category} do
      category_fixture(%{book_id: book.id})

      categories = Category.list_by_book_id!(book.id)

      assert Enum.count(categories) == 1
      refute Enum.member?(categories, category)
    end
  end
end
