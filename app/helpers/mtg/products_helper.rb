# encoding: UTF-8
# make this module available to be included in other areas by using "include Mtg::CardsHelper"
module Mtg::ProductsHelper

  def product_name(product)
    if product.class == Mtg::Card
      product.name
    elsif product.class == Mtg::Cards::Listing || product.class == Mtg::Transactions::Item
      if product.playset
        "Playset: <br/>".html_safe + product.card.name
      else
        display_name(product.card.name)
      end
    elsif product.class == Mtg::Sets::Listing
      "Full Set: <br/>".html_safe + product.set.name
    else
      "unknown"
    end
  end

end