defmodule TerribleWeb.BookLive.FormComponent do
  use TerribleWeb, :live_component

  alias Terrible.Budgeting
  alias Terrible.Budgeting.Book
  alias Terrible.Budgeting.CreateBook

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage book records in your database.</:subtitle>
      </.header>

      <.simple_form
        :let={f}
        for={@form}
        id="book-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={{f, :name}} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Book</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{book: book} = assigns, socket) do
    form =
      if book.id do
        AshPhoenix.Form.for_action(
          book,
          :update,
          as: "book",
          api: Budgeting
        )
      else
        AshPhoenix.Form.for_action(
          Book,
          :create,
          as: "book",
          api: Budgeting
        )
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:form, form)}
  end

  @impl true
  def handle_event("validate", %{"book" => book_params}, socket) do
    {:noreply, assign(socket, :form, AshPhoenix.Form.validate(socket.assigns.form, book_params))}
  end

  def handle_event("save", %{"book" => book_params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, book_params)

    if form.valid? do
      action = socket.assigns.form.type

      case action do
        :update ->
          AshPhoenix.Form.submit(socket.assigns.form, params: book_params)

        :create ->
          book_params
          |> Map.get("name")
          |> CreateBook.run!()
      end

      socket =
        socket
        |> put_flash(:info, "Book #{action}d successfully")
        |> push_navigate(to: socket.assigns.navigate)

      {:noreply, socket}
    else
      {:noreply, assign(socket, form: form)}
    end
  end
end
