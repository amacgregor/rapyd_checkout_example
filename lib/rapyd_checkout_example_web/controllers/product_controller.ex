defmodule RapydCheckoutExampleWeb.ProductController do
  use RapydCheckoutExampleWeb, :controller

  alias RapydCheckoutExample.Catalog
  alias RapydCheckoutExample.Catalog.Product

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
