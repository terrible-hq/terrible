defmodule TerribleWeb.BudgetLive.CategoryComponent do
  use TerribleWeb, :live_component

  require Ash.Query

  alias Ash.Query
  alias Terrible.Budgeting
  alias Terrible.Budgeting.Envelope

  @impl true
  def render(assigns) do
    ~H"""
    <table id={"categories-#{@category.id}"}>
      <thead>
        <tr>
          <th><%= @category.name %></th>
          <th>
            <span>
              <.link patch={~p"/books/#{@book}/budgets/#{@budget.name}/categories/#{@category}/edit"}>
                Edit
              </.link>
            </span>
            <%= unless @envelopes && Enum.any?(@envelopes) do %>
              <span>
                <.link
                  class="delete-category"
                  phx-click={JS.push("delete_category", value: %{id: @category.id})}
                  data-confirm="Are you sure?"
                >
                  Delete
                </.link>
              </span>
            <% end %>
            <span>
              <.link patch={
                ~p"/books/#{@book}/budgets/#{@budget.name}/categories/#{@category}/envelopes/new"
              }>
                New Envelope
              </.link>
            </span>
          </th>
        </tr>
      </thead>
      <tbody>
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
    </table>
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
