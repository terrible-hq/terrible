defmodule TerribleWeb.Layouts do
  @moduledoc false

  use TerribleWeb, :html

  alias Terrible.Utils

  embed_templates "layouts/*"

  def sidebar(assigns) do
    ~H"""
    <div class="hidden lg:fixed lg:inset-y-0 lg:flex lg:w-64 lg:flex-col">
      <div class="flex min-h-0 flex-1 flex-col border-r border-gray-200 bg-white">
        <div class="flex flex-1 flex-col overflow-y-auto pt-5 pb-4">
          <nav class="mt-5 flex-1 space-y-1 bg-white px-2">
            <.link
              navigate={~p"/books/#{@book}/budgets/#{Utils.get_budget_name(Date.utc_today())}"}
              class={
                "group flex items-center rounded-md px-2 py-2 text-sm font-medium #{if @active_nav_item == :budget, do: "bg-gray-100 text-gray-900", else: "text-gray-600 hover:bg-gray-50 hover:text-gray-900"}"
              }
              aria-current={if @active_nav_item == :budget, do: "true", else: "false"}
            >
              <Heroicons.inbox outline class="text-gray-500 mr-4 h-6 w-6 flex-shrink-0" /> Budget
            </.link>
          </nav>
        </div>
        <div>
          <.link patch={~p"/books/#{@book}/budgets/#{Utils.get_budget_name(Date.utc_today())}/accounts/new"}>
            <.button>New Account</.button>
          </.link>
        </div>
        <div id="account-list" phx-update="stream">
          <div
            :for={{id, account} <- @accounts}
            id={id}
          >
            <%= account.name %>
            <.link
              patch={
                ~p"/books/#{@book}/budgets/#{Utils.get_budget_name(Date.utc_today())}/accounts/#{account}/edit"
              }
              class="text-indigo-600 hover:text-indigo-900"
            >
              Edit
            </.link>
            <.link
              class="delete-account text-indigo-600 hover:text-indigo-900"
              phx-click={JS.push("delete_account", value: %{id: account.id}) |> hide("##{id}")}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
