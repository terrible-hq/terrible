defmodule TerribleWeb.BudgetComponents do
  @moduledoc false

  use Phoenix.Component
  use TerribleWeb, :verified_routes

  alias Phoenix.LiveView.JS

  attr :id, :string, required: true
  attr :categories, :list, required: true
  attr :book, :any, required: true
  attr :budget, :any, required: true
  attr :category_id, :any, default: nil, doc: "the function for generating the row id"

  def category_list(assigns) do
    assigns =
      with %{categories: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, category_id: assigns.category_id || fn {id, _category} -> id end)
      end

    ~H"""
    <div class="mt-8 flow-root">
      <div class="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
          <div class="table min-w-full">
            <div class="table-header-group bg-white">
              <div class="table-row">
                <div class="table-cell py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-3">
                  Category
                </div>
                <div class="table-cell px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                  Assigned
                </div>
                <div class="table-cell relative py-3.5 pl-3 pr-4 sm:pr-3">
                  <span class="sr-only">Actions</span>
                </div>
              </div>
              <div id={@id} phx-update="stream">
                <div
                  :for={{_id, category} = row <- @categories}
                  id={@category_id && @category_id.(row)}
                  class="table-row-group bg-white"
                >
                  <div class="table-row border-t border-gray-200">
                    <div class="table-cell bg-gray-50 py-2 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-3">
                      <%= category.name %>
                    </div>
                    <div class="table-cell relative bg-gray-50 py-2 pl-4 pr-3 text-right text-sm font-medium sm:pl-3">
                      <.link
                        patch={
                          ~p"/books/#{@book}/budgets/#{@budget.name}/categories/#{category}/edit"
                        }
                        class="text-indigo-600 hover:text-indigo-900"
                      >
                        Edit
                      </.link>
                      <%= unless Enum.any?(category.envelopes) do %>
                        <.link
                          class="delete-category text-indigo-600 hover:text-indigo-900"
                          phx-click={JS.push("delete_category", value: %{id: category.id})}
                          data-confirm="Are you sure?"
                        >
                          Delete
                        </.link>
                      <% end %>
                      <.link
                        patch={
                          ~p"/books/#{@book}/budgets/#{@budget.name}/categories/#{category}/envelopes/new"
                        }
                        class="text-indigo-600 hover:text-indigo-900"
                      >
                        New Envelope
                      </.link>
                    </div>
                  </div>
                  <div
                    :for={envelope <- category.envelopes}
                    id={"envelopes-#{envelope.id}"}
                    class="table-row border-t border-gray-300"
                  >
                    <div class="table-cell whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-3">
                      <%= envelope.name %>
                    </div>
                    <div class="table-cell whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                      <%= envelope_assigned(envelope) %>
                    </div>
                    <div class="table-cell relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-3">
                      <.link
                        patch={
                          ~p"/books/#{@book}/budgets/#{@budget.name}/categories/#{category}/envelopes/#{envelope}/edit"
                        }
                        class="text-indigo-600 hover:text-indigo-900"
                      >
                        Edit
                      </.link>
                      <.link
                        phx-click={JS.push("delete_envelope", value: %{id: envelope.id})}
                        data-confirm="Are you sure?"
                        class="text-indigo-600 hover:text-indigo-900"
                      >
                        Delete
                      </.link>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp envelope_assigned(envelope) do
    envelope
    |> Map.get(:monthly_envelopes)
    |> Enum.at(0)
    |> Map.get(:assigned_cents)
    |> Kernel./(100)
  end
end
