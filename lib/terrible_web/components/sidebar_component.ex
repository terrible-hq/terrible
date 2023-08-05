defmodule TerribleWeb.SidebarComponent do
  @moduledoc false

  use TerribleWeb, :live_component

  alias Terrible.Utils

  def sidebar_item_class(active) do
    active_class =
      if active do
        "bg-indigo-700 text-white"
      else
        "text-indigo-200 hover:text-white hover:bg-indigo-700"
      end

    "#{active_class} group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold"
  end

  def render(assigns) do
    ~H"""
    <div class="flex grow flex-col gap-y-5 overflow-y-auto bg-indigo-600 px-6 pb-2">
      <div class="flex h-16 shrink-0 justify-center items-center">
        <span class="text-white font-semibold"><%= @book.name %></span>
      </div>
      <nav class="flex flex-1 flex-col">
        <ul role="list" class="flex flex-1 flex-col gap-y-7">
          <li>
            <ul role="list" class="-mx-2 space-y-1">
              <li>
                <.link
                  navigate={~p"/books/#{@book}/budgets/#{Utils.get_budget_name(Date.utc_today())}"}
                  class={sidebar_item_class(@active_nav_item == :budget)}
                  aria-current={if @active_nav_item == :budget, do: "true", else: "false"}
                >
                  <Heroicons.inbox class="text-white h-6 w-6 flex-shrink-0" /> Budget
                </.link>
              </li>
            </ul>
          </li>
          <li>
            <div class="flex justify-between">
              <div class="text-xs font-semibold leading-6 text-indigo-200">Your Accounts</div>
              <div class="text-xs font-semibold leading-6 text-indigo-200 hover:text-white">
                <.link patch={
                  ~p"/books/#{@book}/budgets/#{Utils.get_budget_name(Date.utc_today())}/accounts/new"
                }>
                  Add Account
                </.link>
              </div>
            </div>
            <ul role="list" class="-mx-2 mt-2 space-y-1">
              <div id="account-list" phx-update="stream">
                <div :for={{id, account} <- @accounts} id={id}>
                  <li>
                    <div class={sidebar_item_class(false)}>
                      <div class="flex justify-center items-center">
                        <.link
                          patch={
                            ~p"/books/#{@book}/budgets/#{Utils.get_budget_name(Date.utc_today())}/accounts/#{account}/edit"
                          }
                          class="edit-account"
                        >
                          <span class="sr-only">Edit Account - <%= account.name %></span>
                          <span class="flex h-3 w-3 shrink-0 items-center justify-center font-medium text-indigo-600 hover:text-white">
                            <Heroicons.pencil mini />
                          </span>
                        </.link>
                        <.link
                          class="delete-account"
                          phx-click={
                            JS.push("delete_account", value: %{id: account.id})
                            |> hide("#accounts-#{account.id}")
                          }
                          data-confirm="Are you sure?"
                        >
                          <span class="sr-only">Delete Account - <%= account.name %></span>
                          <span class="flex h-3 w-3 shrink-0 items-center justify-center font-medium text-indigo-600 hover:text-white">
                            <Heroicons.minus_circle mini />
                          </span>
                        </.link>
                      </div>
                      <.link
                        navigate={~p"/books/#{@book}/budgets/#{@budget.name}"}
                        aria-current="false"
                      >
                        <span class="sr-only">View Account - <%= account.name %></span>
                        <span class="truncate"><%= account.name %></span>
                      </.link>
                      <span class="justify-right flex-grow text-right">
                        $999,999.99
                      </span>
                    </div>
                  </li>
                </div>
              </div>
            </ul>
          </li>
        </ul>
      </nav>
    </div>
    """
  end
end
