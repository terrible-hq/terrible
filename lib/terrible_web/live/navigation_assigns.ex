defmodule TerribleWeb.NavigationAssigns do
  @moduledoc """
  Mount hook for doing assigns for navigation-related things.
  """

  use Phoenix.Component

  alias TerribleWeb.BudgetLive

  def on_mount(:default, _params, _session, socket) do
    {:cont, assign_active_nav_item(socket)}
  end

  defp assign_active_nav_item(socket) do
    active_nav_item =
      case socket.view do
        BudgetLive.Show ->
          :budget

        _ ->
          nil
      end

    assign(socket, :active_nav_item, active_nav_item)
  end
end
