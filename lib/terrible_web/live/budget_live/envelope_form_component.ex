defmodule TerribleWeb.BudgetLive.EnvelopeFormComponent do
  use TerribleWeb, :live_component

  alias Terrible.Budgeting
  alias Terrible.Budgeting.CreateEnvelope
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
        <.input field={{f, :name}} type="text" label="Name" />
        <.input field={{f, :category_id}} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Envelope</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{category: category, envelope: envelope} = assigns, socket) do
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
            Ash.Changeset.set_argument(changeset, :category_id, category.id)
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
    form = AshPhoenix.Form.validate(socket.assigns.form, envelope_params)

    if form.valid? do
      action = socket.assigns.form.type

      case action do
        :update ->
          AshPhoenix.Form.submit(
            socket.assigns.form,
            params: envelope_params,
            before_submit: fn changeset ->
              Ash.Changeset.set_argument(changeset, :category_id, socket.assigns.category.id)
            end
          )

        :create ->
          CreateEnvelope.run!(
            Map.get(envelope_params, "name"),
            Map.get(envelope_params, "category_id")
          )
      end

      socket =
        socket
        |> put_flash(:info, "Envelope #{action}d successfully")
        |> push_navigate(to: socket.assigns.navigate)

      {:noreply, socket}
    else
      {:noreply, assign(socket, form: form)}
    end
  end
end
