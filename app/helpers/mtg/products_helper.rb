# encoding: UTF-8
# make this module available to be included in other areas by using "include Mtg::CardsHelper"
module Mtg::ProductsHelper

  def product_name(product, truncate = false)
    product_type = ""
    product_name = ""
    if product.class == Mtg::Card
      product_name = product.name
    elsif product.class == Mtg::Cards::Listing || product.class == Mtg::Transactions::Item
      product_type = "Playset" if product.playset
      product_name = product.card.name
    elsif product.class == Mtg::Sets::Listing
      product_type = "Full Set"
      product_name = product.set.name
    else
      product_name = "Unknown"
    end
    if product_type != ""
      if truncate
        "#{product_type}:<br/>#{product_name.truncate(30, :omission => "...")}".html_safe
      else
        "#{product_type}:<br/>#{product_name}".html_safe
      end
    else
      if truncate
        product_name.html_safe.truncate(30, :omission => "...")
      else
        product_name.html_safe
      end
    end
  end

end