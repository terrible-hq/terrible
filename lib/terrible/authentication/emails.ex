defmodule Terrible.Authentication.Emails do
  @moduledoc """
  Email templates related to Authentication.
  """

  import Swoosh.Email

  def deliver_reset_password_instructions(user, url) do
    build_email(user.email, "Reset Your Password", """
    <html>
      <p>
        Hi #{user.email},
      </p>

      <p>
        <a href="#{url}">Click here</a> to reset your password.
      </p>

      <p>
        If you didn't request this change, please ignore this.
      </p>
    <html>
    """)
  end

  defp build_email(to, subject, body) do
    new()
    |> to(to_string(to))
    |> from({"Terrible", "no-reply@terrible.finance"})
    |> subject(subject)
    |> put_provider_option(:track_links, "None")
    |> html_body(body)
  end
end
