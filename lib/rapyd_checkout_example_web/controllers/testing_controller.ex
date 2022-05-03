def index(conn, _params) do
  response = HTTPoison.get! "https://sandboxapi.rapyd.net/v1/data/countries"
  response = response.body |> Jason.decode!
  render(conn, "index.html", response: response)
end
