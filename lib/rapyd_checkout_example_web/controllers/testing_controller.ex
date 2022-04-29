defmodule RapydCheckoutExampleWeb.TestingController do
  use RapydCheckoutExampleWeb, :controller

  def index(conn, _params) do
    # Define the base url and target path
    base_url = "https://sandboxapi.rapyd.net"
    url_path = "/v1/data/countries"

    # Generate the values needed for the headers
    access_key = Application.fetch_env!(:rapyd_checkout_example, :rapyd_access_key)
    salt = :crypto.strong_rand_bytes(8) |> Base.encode64() |> binary_part(0, 8)
    timestamp = System.os_time(:second)
    signature = sign_request("get", url_path, salt, timestamp, access_key, "")

    # Build the headers
    headers = [
      {"access_key", access_key},
      {"salt", salt},
      {"timestamp", timestamp},
      {"url_path", url_path},
      {"signature", signature}
    ]

    response = HTTPoison.get!(base_url <> url_path, headers)
    response = response.body |> Jason.decode!()
    render(conn, "index.html", response: response)
  end

  def sign_request(http_method, url_path, salt, timestamp, access_key, body) do
    secret_key = Application.fetch_env!(:rapyd_checkout_example, :rapyd_secret_key)

    cond do
      body == "" ->
        body = ""

      true ->
        {:ok, body} = body |> Jason.encode()
    end

    signature_string =
      [http_method, url_path, salt, timestamp, access_key, secret_key, body] |> Enum.join("")

    :crypto.mac(:hmac, :sha256, secret_key, signature_string)
    |> Base.encode16(case: :lower)
    |> Base.encode64()
  end
end
