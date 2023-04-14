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
      rows={@streams.books}
      row_click={fn {_id, book} -> JS.navigate(~p"/books/#{book}/budgets/#{@budget_name}") end}
    >
      <:col :let={{_id, book}} label="Name"><%= book.name %></:col>
      <:action :let={{_id, book}}>
        <div class="sr-only">
          <.link navigate={~p"/books/#{book}/budgets/#{@budget_name}"}>Show</.link>
        </div>
        <.link patch={~p"/books/#{book}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, book}}>
        <.link
          phx-click={JS.push("delete", value: %{id: book.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="book-modal" show on_cancel={JS.patch(~p"/books")}>
      <.live_component
        module={TerribleWeb.BookLive.FormComponent}
        current_user={@current_user}
        id={@book.id || :new}
        title={@page_title}
        action={@live_action}
        book={@book}
        patch={~p"/books"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    books = Book.list!(socket.assigns.current_user.id)

    socket =
      socket
      |> assign(:budget_name, Utils.get_budget_name(Date.utc_today()))
      |> stream(:books, books)

    if connected?(socket) do
      TerribleWeb.Endpoint.subscribe("books:created")

      for book <- books do
        book_subscribe(book)
      end
    end

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

    {:noreply, stream_delete(socket, :books, book)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "books:created",
          payload: %Ash.Notifier.Notification{data: %{id: id}}
        },
        socket
      ) do
    book = Book.get!(id, load: [visible_to: %{user_id: socket.assigns.current_user.id}])

    if book.visible_to do
      if connected?(socket) do
        book_subscribe(book)
      end

      {:noreply, stream_insert(socket, :books, book)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "books:updated:" <> id
        },
        socket
      ) do
    book = Book.get!(id)

    {:noreply, stream_insert(socket, :books, book)}
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

  defp book_subscribe(book) do
    TerribleWeb.Endpoint.subscribe("books:updated:#{book.id}")
  end
end
