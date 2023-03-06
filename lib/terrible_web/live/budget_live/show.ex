defmodule TerribleWeb.BudgetLive.Show do
  use TerribleWeb, :live_view

  alias Terrible.Budgeting.{Book, Budget, Category, Envelope}
  alias Terrible.Budgeting.DestroyEnvelope
  alias TerribleWeb.BudgetLive.CategoryComponent

  @impl true
  def mount(%{"book_id" => book_id}, _session, socket) do
    if connected?(socket) do
      with {:ok, book} <- Book.get_by_id(book_id) do
        Phoenix.PubSub.subscribe(Terrible.PubSub, "book:" <> book.id)
      end
    end

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

  defp apply_action(socket, :new_envelope, %{
         "book_id" => book_id,
         "name" => name,
         "category_id" => category_id
       }) do
    book = Book.get_by_id!(book_id)
    budget = Budget.get_by_book_id_and_name!(book_id, name)
    categories = Category.list_by_book_id!(book.id)
    category = Category.get_by_id!(category_id)

    socket
    |> assign(:page_title, "New Envelope | #{book.name}")
    |> assign(:form_title, "Create New Envelope")
    |> assign(:book, book)
    |> assign(:budget, budget)
    |> assign(:categories, categories)
    |> assign(:category, category)
    |> assign(:envelope, %Envelope{})
  end

  defp apply_action(socket, :edit_envelope, %{
         "book_id" => book_id,
         "name" => name,
         "category_id" => category_id,
         "envelope_id" => envelope_id
       }) do
    book = Book.get_by_id!(book_id)
    budget = Budget.get_by_book_id_and_name!(book_id, name)
    categories = Category.list_by_book_id!(book.id)
    category = Category.get_by_id!(category_id)
    envelope = Envelope.get_by_id!(envelope_id)

    socket
    |> assign(:page_title, "Edit Envelope | #{book.name}")
    |> assign(:form_title, "Edit Envelope")
    |> assign(:book, book)
    |> assign(:budget, budget)
    |> assign(:categories, categories)
    |> assign(:category, category)
    |> assign(:envelope, envelope)
  end

  @impl true
  def handle_event("delete_category", %{"id" => id}, socket) do
    category = Category.get_by_id!(id)
    book_id = category.book_id
    :ok = Category.destroy(category)

    {:noreply, assign(socket, :categories, Category.list_by_book_id!(book_id))}
  end

  @impl true
  def handle_event("delete_envelope", %{"id" => id}, socket) do
    envelope = Envelope.get_by_id!(id)
    category = Category.get_by_id!(envelope.category_id)
    DestroyEnvelope.run!(envelope.id)

    {:noreply, assign(socket, :categories, Category.list_by_book_id!(category.book_id))}
  end

  @impl true
  def handle_info({:destroyed_envelope, payload}, socket) do
    send_update(CategoryComponent, id: payload.category_id)

    {:noreply, socket}
  end
end
