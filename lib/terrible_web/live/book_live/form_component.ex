defmodule TerribleWeb.BookLive.FormComponent do
  use TerribleWeb, :live_component

  alias Terrible.Budgeting
  alias Terrible.Budgeting.Book

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
    case AshPhoenix.Form.submit(socket.assigns.form, params: book_params) do
      {:ok, _book} ->
        message =
          case socket.assigns.form.type do
            :create ->
              "Book created successfully"

            :update ->
              "Book updated successfully"
          end

        socket =
          socket
          |> put_flash(:info, message)
          |> push_navigate(to: socket.assigns.navigate)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
