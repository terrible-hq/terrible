defmodule TerribleWeb.BudgetLive.Show do
  use TerribleWeb, :live_view

  alias Terrible.Budgeting.{Book, Budget}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, %{"book_id" => book_id, "name" => name}) do
    book = Book.get_by_id!(book_id)
    budget = Budget.get_by_book_id_and_name!(book_id, name)

    socket
    |> assign(:page_title, "Budget | #{book.name}")
    |> assign(:book, book)
    |> assign(:budget, budget)
  end
end
