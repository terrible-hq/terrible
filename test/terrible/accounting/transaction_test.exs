defmodule Terrible.Accounting.TransactionTest do
  use Terrible.DataCase

  alias Terrible.Accounting.Transaction

  describe "create" do
    setup do
      book = book_fixture()
      system_category = category_fixture(%{book_id: book.id, type: :system})
      unassigned_envelope = envelope_fixture(%{book_id: book.id, category_id: system_category.id, type: :unassigned})
      category = category_fixture(%{book_id: book.id})
      envelope = envelope_fixture(%{book_id: book.id, category_id: category.id})

      %{
        book: book,
        system_category: system_category,
        unassigned_envelope: unassigned_envelope,
        category: category,
        envelope: envelope
      }
    end

    test "creates a transaction", %{book: book, unassigned_envelope: unassigned_envelope, envelope: envelope} do
      attrs = %{
        date: Date.utc_today(),
        book_id: book.id,
        entries: [
          %{
            source_id: unassigned_envelope.id,
            source_type: :envelope,
            destination_id: envelope.id,
            destination_type: :envelope,
            amount: 100
          }
        ]
      }

      {:ok, transaction} = Transaction.create(attrs)

      assert transaction.id
      assert transaction.book_id == book.id
      assert transaction.date == Date.utc_today()
    end
  end
end
