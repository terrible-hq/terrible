defmodule TerribleWeb.BudgetLive.AccountFormComponent do
  use TerribleWeb, :live_component

  alias Terrible.Accounting
  alias Terrible.Accounting.Account

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
        id="account-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={f[:name]} type="text" label="Name" />

        <.input
          :if={@form.action == :create}
          label="Account Type"
          field={f[:account_type_id]}
          type="select"
          prompt="Select Account Type"
          options={Enum.map(@account_types, &{&1.name, &1.id})}
        />

        <.input field={f[:book_id]} type="hidden" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Account</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{account: account, book: book} = assigns, socket) do
    form =
      if account.id do
        AshPhoenix.Form.for_action(
          account,
          :update,
          as: "account",
          api: Accounting
        )
      else
        AshPhoenix.Form.for_action(
          Account,
          :create,
          as: "account",
          api: Accounting,
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
  def handle_event("validate", %{"account" => account_params}, socket) do
    {:noreply,
     assign(socket, :form, AshPhoenix.Form.validate(socket.assigns.form, account_params))}
  end

  def handle_event("save", %{"account" => account_params}, socket) do
    case AshPhoenix.Form.submit(
           socket.assigns.form,
           params: account_params,
           before_submit: fn changeset ->
             Ash.Changeset.set_argument(changeset, :book_id, socket.assigns.book.id)
           end
         ) do
      {:ok, _account} ->
        message =
          case socket.assigns.form.type do
            :create ->
              "Account created successfully"

            :update ->
              "Account updated successfully"
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
