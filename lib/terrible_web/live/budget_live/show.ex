defmodule TerribleWeb.BudgetLive.Show do
  use TerribleWeb, :live_view

  require Ash.Query

  alias Terrible.Accounting.{Account, AccountType}
  alias Terrible.Budgeting.{Book, Budget, Category, Envelope, MonthlyEnvelope}
  alias TerribleWeb.BudgetComponents

  alias TerribleWeb.BudgetLive.{
    AccountFormComponent,
    CategoryFormComponent,
    EnvelopeFormComponent
  }

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Your Budget - <%= @book.name %>
      <:actions>
        <.link patch={~p"/books/#{@book}/budgets/#{@budget.name}/categories/new"}>
          <.button>New Category</.button>
        </.link>
      </:actions>
    </.header>

    <h1>Welcome!</h1>

    <div class="mt-8 flow-root">
      <div class="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
          <BudgetComponents.category_list
            id="category-list"
            categories={@streams.categories}
            book={@book}
            budget={@budget}
          />
        </div>
      </div>
    </div>

    <.modal
      :if={@live_action in [:new_account, :edit_account]}
      id="account-modal"
      show
      on_cancel={JS.patch(~p"/books/#{@book}/budgets/#{@budget.name}")}
    >
      <.live_component
        module={AccountFormComponent}
        id={@account.id || :new}
        title={@form_title}
        book={@book}
        account={@account}
        account_types={@account_types}
        patch={~p"/books/#{@book.id}/budgets/#{@budget.name}"}
      />
    </.modal>

    <.modal
      :if={@live_action in [:new_category, :edit_category]}
      id="category-modal"
      show
      on_cancel={JS.patch(~p"/books/#{@book}/budgets/#{@budget.name}")}
    >
      <.live_component
        module={CategoryFormComponent}
        id={@category.id || :new}
        title={@form_title}
        book={@book}
        category={@category}
        patch={~p"/books/#{@book.id}/budgets/#{@budget.name}"}
      />
    </.modal>

    <.modal
      :if={@live_action in [:new_envelope, :edit_envelope]}
      id="envelope-modal"
      show
      on_cancel={JS.patch(~p"/books/#{@book}/budgets/#{@budget.name}")}
    >
      <.live_component
        module={EnvelopeFormComponent}
        id={@envelope.id || :new}
        title={@form_title}
        book={@book}
        category={@category}
        envelope={@envelope}
        patch={~p"/books/#{@book.id}/budgets/#{@budget.name}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    with {:ok, book} <- Book.get(params["book_id"]),
         {:ok, budget} <- Budget.get_by_book_id_and_name(book.id, params["name"]) do
      accounts = Account.list_by_book_id!(book.id)
      account_types = AccountType.list!()
      categories = Category.list_by_book_id!(book.id, load: category_preloads(budget.id))

      if connected?(socket) do
        TerribleWeb.Endpoint.subscribe("accounts:created")
        TerribleWeb.Endpoint.subscribe("categories:created")
        TerribleWeb.Endpoint.subscribe("envelopes:created")

        for account <- accounts do
          account_subscribe(account)
        end

        for category <- categories do
          category_subscribe(category)
        end
      end

      {:ok,
       socket
       |> assign(:book, book)
       |> assign(:budget, budget)
       |> assign(:account_types, account_types)
       |> stream(:accounts, accounts)
       |> stream(:categories, categories)
       |> assign(:category, nil)
       |> assign(:envelope, nil)
       |> assign(:account, nil)}
    else
      _ ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :show, _params) do
    socket
    |> assign(:page_title, "Budget | #{socket.assigns.book.name}")
    |> assign(:account, nil)
    |> assign(:category, nil)
    |> assign(:envelope, nil)
  end

  defp apply_action(socket, :new_account, _params) do
    socket
    |> assign(:page_title, "New Account | #{socket.assigns.book.name}")
    |> assign(:form_title, "Create New Account")
    |> assign(:account, %Account{})
  end

  defp apply_action(socket, :edit_account, %{
         "account_id" => account_id
       }) do
    account = Account.get!(account_id)

    socket
    |> assign(:page_title, "Edit Account | #{socket.assigns.book.name}")
    |> assign(:form_title, "Edit Account")
    |> assign(:account, account)
  end

  defp apply_action(socket, :new_category, _params) do
    socket
    |> assign(:page_title, "New Category | #{socket.assigns.book.name}")
    |> assign(:form_title, "Create New Category")
    |> assign(:category, %Category{})
  end

  defp apply_action(socket, :edit_category, %{
         "category_id" => category_id
       }) do
    category = Category.get!(category_id)

    socket
    |> assign(:page_title, "Edit Category | #{socket.assigns.book.name}")
    |> assign(:form_title, "Edit Category")
    |> assign(:category, category)
  end

  defp apply_action(socket, :new_envelope, %{
         "category_id" => category_id
       }) do
    category = Category.get!(category_id)

    socket
    |> assign(:page_title, "New Envelope | #{socket.assigns.book.name}")
    |> assign(:form_title, "Create New Envelope")
    |> assign(:category, category)
    |> assign(:envelope, %Envelope{})
  end

  defp apply_action(socket, :edit_envelope, %{
         "category_id" => category_id,
         "envelope_id" => envelope_id
       }) do
    category = Category.get!(category_id)
    envelope = Envelope.get!(envelope_id)

    socket
    |> assign(:page_title, "Edit Envelope | #{socket.assigns.book.name}")
    |> assign(:form_title, "Edit Envelope")
    |> assign(:category, category)
    |> assign(:envelope, envelope)
  end

  @impl true
  def handle_event("delete_account", %{"id" => id}, socket) do
    account = Account.get!(id)
    :ok = Account.destroy(account)

    {:noreply, stream_delete(socket, :accounts, account)}
  end

  @impl true
  def handle_event("delete_category", %{"id" => id}, socket) do
    category = Category.get!(id)
    :ok = Category.destroy(category)

    {:noreply, stream_delete(socket, :categories, category)}
  end

  @impl true
  def handle_event("delete_envelope", %{"id" => id}, socket) do
    envelope = Envelope.get!(id)
    :ok = Envelope.destroy(envelope)

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "accounts:created",
          payload: %Ash.Notifier.Notification{data: %{id: id}}
        },
        socket
      ) do
    account = Account.get!(id)

    if connected?(socket) do
      account_subscribe(account)
    end

    {:noreply, stream_insert(socket, :accounts, account)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "accounts:updated:" <> id
        },
        socket
      ) do
    account = Account.get!(id)

    {:noreply, stream_insert(socket, :accounts, account, at: -1)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "categories:created",
          payload: %Ash.Notifier.Notification{data: %{id: id}}
        },
        socket
      ) do
    category = Category.get!(id, load: category_preloads(socket.assigns.budget.id))

    if connected?(socket) do
      category_subscribe(category)
    end

    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "categories:updated:" <> id
        },
        socket
      ) do
    category = Category.get!(id, load: category_preloads(socket.assigns.budget.id))

    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "envelopes:created",
          payload: %Ash.Notifier.Notification{data: %{id: id}}
        },
        socket
      ) do
    with {:ok, envelope} <- Envelope.get(id),
         {:ok, category} <-
           Category.get(envelope.category_id, load: category_preloads(socket.assigns.budget.id)) do
      envelope_subscribe(envelope)

      {:noreply, stream_insert(socket, :categories, category)}
    else
      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "envelopes:updated:" <> id
        },
        socket
      ) do
    category =
      id
      |> Envelope.get!()
      |> Map.get(:category_id)
      |> Category.get!(load: category_preloads(socket.assigns.budget.id))

    {:noreply, stream_insert(socket, :categories, category)}
  end

  @impl true
  def handle_info(
        %Phoenix.Socket.Broadcast{
          topic: "envelopes:destroyed:" <> _id,
          payload: %Ash.Notifier.Notification{data: data}
        },
        socket
      ) do
    category = Category.get!(data.category_id, load: category_preloads(socket.assigns.budget.id))

    {:noreply, stream_insert(socket, :categories, category)}
  end

  defp category_preloads(budget_id) do
    [
      envelopes: [
        monthly_envelopes: Ash.Query.filter(MonthlyEnvelope, budget_id == ^budget_id)
      ]
    ]
  end

  defp account_subscribe(account) do
    TerribleWeb.Endpoint.subscribe("accounts:updated:#{account.id}")
  end

  defp category_subscribe(category) do
    TerribleWeb.Endpoint.subscribe("categories:updated:#{category.id}")

    for envelope <- category.envelopes do
      envelope_subscribe(envelope)
    end
  end

  defp envelope_subscribe(envelope) do
    TerribleWeb.Endpoint.subscribe("envelopes:updated:#{envelope.id}")
    TerribleWeb.Endpoint.subscribe("envelopes:destroyed:#{envelope.id}")
  end
end
