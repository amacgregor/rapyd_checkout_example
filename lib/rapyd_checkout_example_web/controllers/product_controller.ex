defmodule RapydCheckoutExampleWeb.ProductController do
  use RapydCheckoutExampleWeb, :controller

  alias RapydCheckoutExample.Catalog
  alias RapydCheckoutExample.Catalog.Product

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def hosted_checkout(conn, _params) do
    render(conn, "hosted-checkout.html")
  end

  def toolkit_checkout(conn, _params) do
    render(conn, "toolkit-checkout.html")
  end

  def checkout(conn, _params) do
    # Create the body
    {:ok, body} =
      %{
        amount: "220.00",
        currency: "USD",
        country: "US"
      }
      |> Jason.encode()

    response = generate_checkout(body)

    IO.inspect(response)

    render(conn, "checkout.html", checkout_id: response["data"]["id"])
  end

  def checkout_redirect(conn, _params) do
    # Create the body
    {:ok, body} =
      %{
        amount: "140.00",
        currency: "USD",
        country: "US"
      }
      |> Jason.encode()

    response = generate_checkout(body)

    # Redirect to the checkout page
    redirect(conn, external: response["data"]["redirect_url"])
  end

  defp generate_checkout(body) do
    # Define the base url and target path
    base_url = "https://sandboxapi.rapyd.net"
    url_path = "/v1/checkout"

    # Generate the values needed for the headers
    access_key = Application.fetch_env!(:rapyd_checkout_example, :rapyd_access_key)
    salt = :crypto.strong_rand_bytes(8) |> Base.encode64() |> binary_part(0, 8)
    timestamp = System.os_time(:second)

    signature = sign_request("post", url_path, salt, timestamp, access_key, to_string(body))

    # Build the headers
    headers = [
      {"access_key", access_key},
      {"salt", salt},
      {"timestamp", timestamp},
      {"url_path", url_path},
      {"signature", signature}
    ]

    response = HTTPoison.post!(base_url <> url_path, body, headers)
    response = response.body |> Jason.decode!()
  end

  defp sign_request(http_method, url_path, salt, timestamp, access_key, body) do
    secret_key = Application.fetch_env!(:rapyd_checkout_example, :rapyd_secret_key)

    signature_string =
      [http_method, url_path, salt, timestamp, access_key, secret_key, body] |> Enum.join("")

    :crypto.mac(:hmac, :sha256, secret_key, signature_string)
    |> Base.encode16(case: :lower)
    |> Base.encode64()
  end
end
