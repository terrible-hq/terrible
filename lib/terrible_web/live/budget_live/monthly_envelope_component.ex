defmodule TerribleWeb.BudgetLive.MonthlyEnvelopeComponent do
  use TerribleWeb, :live_component

  require Ash.Query

  alias Ash.Query
  alias Terrible.Budgeting
  alias Terrible.Budgeting.MonthlyEnvelope

  @impl true
  def render(assigns) do
    ~H"""
    <tr id={"envelopes-#{@envelope.id}"}>
      <td><%= @envelope.name %></td>
      <td>
        <span>
          <.link patch={
            ~p"/books/#{@book}/budgets/#{@budget.name}/categories/#{@category}/envelopes/#{@envelope}/edit"
          }>
            Edit
          </.link>
        </span>
        <span>
          <.link
            phx-click={JS.push("delete_envelope", value: %{id: @envelope.id})}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </span>
      </td>
      <td><%= cents_to_whole(@monthly_envelope.assigned_cents) %></td>
    </tr>
    """
  end

  @impl true
  def preload(list_of_assigns) do
    list_of_envelope_ids = Enum.map(list_of_assigns, & &1.id)

    budget =
      list_of_assigns
      |> Enum.at(0)
      |> Map.get(:budget)

    monthly_envelopes =
      MonthlyEnvelope
      |> Query.for_read(:read)
      |> Query.filter(budget_id == ^budget.id)
      |> Query.filter(envelope_id in ^list_of_envelope_ids)
      |> Budgeting.read!()
      |> Map.new(&{&1.envelope_id, &1})

    Enum.map(list_of_assigns, fn assigns ->
      Map.put(assigns, :monthly_envelope, monthly_envelopes[assigns.id])
    end)
  end

  defp cents_to_whole(amount_in_cents) do
    amount_in_cents / 100
  end
end
