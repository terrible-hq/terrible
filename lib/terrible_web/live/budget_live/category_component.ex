defmodule TerribleWeb.BudgetLive.CategoryComponent do
  use TerribleWeb, :live_component

  require Ash.Query

  alias Ash.Query
  alias Terrible.Budgeting
  alias Terrible.Budgeting.Envelope

  @impl true
  def render(assigns) do
    ~H"""
    <tbody id={"categories-#{@category.id}"} class="bg-white">
      <tr class="border-t border-gray-200">
        <th
          colspan="2"
          scope="colgroup"
          class="bg-gray-50 py-2 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-3"
        >
          <%= @category.name %>
        </th>
        <th
          scope="colgroup"
          class="relative bg-gray-50 py-2 pl-4 pr-3 text-right text-sm font-medium sm:pl-3"
        >
          <.link
            patch={~p"/books/#{@book}/budgets/#{@budget.name}/categories/#{@category}/edit"}
            class="text-indigo-600 hover:text-indigo-900"
          >
            Edit
          </.link>
          <%= unless @envelopes && Enum.any?(@envelopes) do %>
            <.link
              class="delete-category text-indigo-600 hover:text-indigo-900"
              phx-click={JS.push("delete_category", value: %{id: @category.id})}
              data-confirm="Are you sure?"
            >
              Delete
            </.link>
          <% end %>
          <.link
            patch={~p"/books/#{@book}/budgets/#{@budget.name}/categories/#{@category}/envelopes/new"}
            class="text-indigo-600 hover:text-indigo-900"
          >
            New Envelope
          </.link>
        </th>
      </tr>

      <%= if @envelopes && Enum.any?(@envelopes) do %>
        <%= for envelope <- @envelopes do %>
          <.live_component
            module={TerribleWeb.BudgetLive.MonthlyEnvelopeComponent}
            id={envelope.id}
            book={@book}
            budget={@budget}
            category={@category}
            envelope={envelope}
          />
        <% end %>
      <% end %>
    </tbody>
    """
  end

  @impl true
  def preload(list_of_assigns) do
    list_of_category_ids = Enum.map(list_of_assigns, & &1.id)

    envelopes =
      Envelope
      |> Query.for_read(:read)
      |> Query.filter(category_id in ^list_of_category_ids)
      |> Budgeting.read!()
      |> Enum.reduce(Map.new(), fn envelope, acc ->
        if Map.has_key?(acc, envelope.category_id) do
          Map.put(acc, envelope.category_id, acc[envelope.category_id] ++ [envelope])
        else
          Map.put(acc, envelope.category_id, [envelope])
        end
      end)

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :envelopes, envelopes[assigns.id])
    end)
  end
end
