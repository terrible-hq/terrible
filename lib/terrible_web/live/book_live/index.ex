defmodule TerribleWeb.BookLive.Index do
  use TerribleWeb, :live_view

  alias Terrible.Budgeting.Book
  alias Terrible.Utils

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Books
      <:actions>
        <.link patch={~p"/books/new"}>
          <.button>New Book</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="books"
      rows={@books}
      row_click={&JS.navigate(~p"/books/#{&1}/budgets/#{@budget_name}")}
    >
      <:col :let={book} label="Name"><%= book.name %></:col>
      <:action :let={book}>
        <div class="sr-only">
          <.link navigate={~p"/books/#{book}/budgets/#{@budget_name}"}>Show</.link>
        </div>
        <.link patch={~p"/books/#{book}/edit"}>Edit</.link>
      </:action>
      <:action :let={book}>
        <.link phx-click={JS.push("delete", value: %{id: book.id})} data-confirm="Are you sure?">
          Delete
        </.link>
      </:action>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="book-modal"
      show
      on_cancel={JS.navigate(~p"/books")}
    >
      <.live_component
        module={TerribleWeb.BookLive.FormComponent}
        current_user={@current_user}
        id={@book.id || :new}
        title={@page_title}
        action={@live_action}
        book={@book}
        navigate={~p"/books"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:books, Book.list!(socket.assigns.current_user.id))
      |> assign(:budget_name, Utils.get_budget_name(Date.utc_today()))

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Book.get!(id)
    :ok = Book.destroy(book)

    {:noreply, assign(socket, :books, Book.list!(socket.assigns.current_user.id))}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, Book.get!(id))
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
end
