defmodule Terrible.UtilsTest do
  use Terrible.DataCase

  alias Terrible.Utils

  test "get_budget_name/1 with valid Date.new object returns the correct name" do
    date = Date.new!(2023, 2, 26)

    assert Utils.get_budget_name(date) == "202302"
  end

  test "get_budget_name/1 with valid Date sigil object returns the correct name" do
    date = ~D[2018-08-18]

    assert Utils.get_budget_name(date) == "201808"
  end

  test "get_budget_name/1 with DateTime object returns nil" do
    assert Utils.get_budget_name(DateTime.utc_now()) == nil
  end
end
