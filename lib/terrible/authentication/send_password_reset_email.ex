defmodule Terrible.Authentication.SendPasswordResetEmail do
  @moduledoc """
  Sends a password reset email
  """

  use AshAuthentication.Sender
  use TerribleWeb, :verified_routes

  alias Terrible.Authentication.Emails
  alias Terrible.Mailer

  @impl AshAuthentication.Sender
  def send(user, token, _) do
    user
    |> Emails.deliver_reset_password_instructions(url(~p"/password-reset/#{token}"))
    |> Mailer.deliver!()
  end
end
