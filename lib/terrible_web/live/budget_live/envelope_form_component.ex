defmodule TerribleWeb.BudgetLive.EnvelopeFormComponent do
  use TerribleWeb, :live_component

  alias Terrible.Budgeting
  alias Terrible.Budgeting.Envelope

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
        id="envelope-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={f[:name]} type="text" label="Name" />
        <.input field={f[:book_id]} type="hidden" />
        <.input field={f[:category_id]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Envelope</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{book: book, category: category, envelope: envelope} = assigns, socket) do
    form =
      if envelope.id do
        AshPhoenix.Form.for_action(
          envelope,
          :update,
          as: "envelope",
          api: Budgeting
        )
      else
        AshPhoenix.Form.for_action(
          Envelope,
          :create,
          as: "envelope",
          api: Budgeting,
          prepare_source: fn changeset ->
            changeset
            |> Ash.Changeset.set_argument(:book_id, book.id)
            |> Ash.Changeset.set_argument(:category_id, category.id)
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
  def handle_event("validate", %{"envelope" => envelope_params}, socket) do
    {:noreply,
     assign(socket, :form, AshPhoenix.Form.validate(socket.assigns.form, envelope_params))}
  end

  def handle_event("save", %{"envelope" => envelope_params}, socket) do
    case AshPhoenix.Form.submit(
           socket.assigns.form,
           params: envelope_params,
           before_submit: fn changeset ->
             changeset
             |> Ash.Changeset.set_argument(:book_id, socket.assigns.book.id)
             |> Ash.Changeset.set_argument(:category_id, socket.assigns.category.id)
           end
         ) do
      {:ok, _envelope} ->
        message = "Envelope #{socket.assigns.form.type}d successfully"

        socket =
          socket
          |> put_flash(:info, message)
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end
end
