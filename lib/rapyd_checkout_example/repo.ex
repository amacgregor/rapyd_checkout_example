defmodule RapydCheckoutExample.Repo do
  use Ecto.Repo,
    otp_app: :rapyd_checkout_example,
    adapter: Ecto.Adapters.Postgres
end
