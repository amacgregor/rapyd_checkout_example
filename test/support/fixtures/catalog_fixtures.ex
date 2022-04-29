defmodule RapydCheckoutExample.CatalogFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `RapydCheckoutExample.Catalog` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> RapydCheckoutExample.Catalog.create_product()

    product
  end
end
