defmodule TerribleWeb.BudgetLive.CategoryFormComponent do
  use TerribleWeb, :live_component

  alias Terrible.Budgeting
  alias Terrible.Budgeting.Category

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <.simple_form
        :let={f}
        for={@form}
        id="category-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={f[:name]} type="text" label="Name" />
        <.input field={f[:book_id]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Category</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{category: category, book: book} = assigns, socket) do
    form =
      if category.id do
        AshPhoenix.Form.for_action(
          category,
          :update,
          as: "category",
          api: Budgeting
        )
      else
        AshPhoenix.Form.for_action(
          Category,
          :create,
          as: "category",
          api: Budgeting,
          prepare_source: fn changeset ->
            Ash.Changeset.set_argument(changeset, :book_id, book.id)
          end
        )
      end

    socket =
      socket
      |> assign(assigns)
      |> assign(:form, form)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"category" => category_params}, socket) do
    {:noreply,
     assign(socket, :form, AshPhoenix.Form.validate(socket.assigns.form, category_params))}
  end

  def handle_event("save", %{"category" => category_params}, socket) do
    case AshPhoenix.Form.submit(
           socket.assigns.form,
           params: category_params,
           before_submit: fn changeset ->
             Ash.Changeset.set_argument(changeset, :book_id, socket.assigns.book.id)
           end
         ) do
      {:ok, _category} ->
        message =
          case socket.assigns.form.type do
            :create ->
              "Category created successfully"

            :update ->
              "Category updated successfully"
          end

        socket =
          socket
          |> put_flash(:info, message)
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end
end
