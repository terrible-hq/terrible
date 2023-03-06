defmodule Terrible.Budgeting.DestroyEnvelope do
  @moduledoc """
  A flow module for deleting an Envelope and all the MonthlyEnvelope
  records associated with it.
  """

  use Ash.Flow, otp_app: :terrible

  alias Terrible.Budgeting.Envelope
  alias Terrible.Budgeting.DestroyEnvelope.{BroadcastDestroyEvent, DestroyMonthlyEnvelopes}

  flow do
    api Terrible.Budgeting

    description "A flow module for deleting an Envelope and all the MonthlyEnvelope records associated with it."

    argument :id, :uuid do
      allow_nil? false
    end

    returns :get_envelope
  end

  steps do
    read :get_envelope, Envelope, :by_id do
      input %{
        id: arg(:id)
      }
    end

    custom :destroy_monthly_envelopes, DestroyMonthlyEnvelopes do
      input result(:get_envelope)
    end

    destroy :destroy_envelope, Envelope, :destroy do
      record result(:destroy_monthly_envelopes)
    end

    custom :broadcast_destroy_event, BroadcastDestroyEvent do
      input result(:destroy_envelope)
    end
  end
end
