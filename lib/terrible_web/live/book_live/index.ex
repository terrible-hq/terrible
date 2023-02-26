defmodule TerribleWeb.BookLive.Index do
  use TerribleWeb, :live_view

  alias Terrible.Budgeting.Book
  alias Terrible.Utils

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:books, Book.read_all!())
      |> assign(:budget_name, Utils.get_budget_name(Date.utc_today()))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, Book.get_by_id!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, %Book{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Books")
    |> assign(:book, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Book.get_by_id!(id)
    :ok = Book.destroy(book)

    {:noreply, assign(socket, :books, Book.read_all!())}
  end
end
