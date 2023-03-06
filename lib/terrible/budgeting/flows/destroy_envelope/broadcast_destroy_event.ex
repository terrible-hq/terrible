defmodule Terrible.Budgeting.DestroyEnvelope.BroadcastDestroyEvent do
  @moduledoc """
  Broadcasts the DestroyEnvelope event to Phoenix PubSub.
  """

  use Ash.Flow.Step

  alias Terrible.Budgeting.Category

  def run(envelope, _opts, _context) do
    category = Category.get_by_id!(envelope.category_id)

    message = {:destroyed_envelope, %{id: envelope.id, category_id: category.id}}
    Phoenix.PubSub.broadcast(Terrible.PubSub, "book:" <> category.book_id, message)

    {:ok, envelope}
  end
end
