defmodule TerribleWeb.BudgetLive.Show do
  use TerribleWeb, :live_view

  alias Terrible.Budgeting.{Book, Budget, Category}

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
    categories = Category.list_by_book_id!(book.id)

    socket
    |> assign(:page_title, "Budget | #{book.name}")
    |> assign(:book, book)
    |> assign(:budget, budget)
    |> assign(:categories, categories)
  end

  defp apply_action(socket, :new_category, %{"book_id" => book_id, "name" => name}) do
    book = Book.get_by_id!(book_id)
    budget = Budget.get_by_book_id_and_name!(book_id, name)
    categories = Category.list_by_book_id!(book.id)

    socket
    |> assign(:page_title, "New Category | #{book.name}")
    |> assign(:form_title, "Create New Category")
    |> assign(:book, book)
    |> assign(:budget, budget)
    |> assign(:categories, categories)
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :edit_category, %{
         "book_id" => book_id,
         "name" => name,
         "category_id" => category_id
       }) do
    book = Book.get_by_id!(book_id)
    budget = Budget.get_by_book_id_and_name!(book_id, name)
    categories = Category.list_by_book_id!(book.id)
    category = Category.get_by_id!(category_id)

    socket
    |> assign(:page_title, "Edit Category | #{book.name}")
    |> assign(:form_title, "Edit Category")
    |> assign(:book, book)
    |> assign(:budget, budget)
    |> assign(:categories, categories)
    |> assign(:category, category)
  end

  @impl true
  def handle_event("delete_category", %{"id" => id}, socket) do
    category = Category.get_by_id!(id)
    book_id = category.book_id
    :ok = Category.destroy(category)

    {:noreply, assign(socket, :categories, Category.list_by_book_id!(book_id))}
  end
end
