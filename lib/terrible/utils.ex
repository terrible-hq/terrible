defmodule Terrible.Utils do
  @moduledoc """
  Commonly-used functions that are useful throughout the app.
  """

  @doc """
  Returns a string from the given date that matches the naming
  criteria that we use for Budget records

  ## Examples

      get_budget_name(~D[2005-05-08])
      => "200005"

      get_budget_name(Date.new!(2023, 2, 26))
      => "202302"

      get_budget_name(DateTime.utc_now())
      => nil
  """
  def get_budget_name(%Date{} = date) do
    date
    |> Date.to_string()
    |> String.slice(0..6)
    |> String.replace("-", "")
  end

  def get_budget_name(_), do: nil
end
