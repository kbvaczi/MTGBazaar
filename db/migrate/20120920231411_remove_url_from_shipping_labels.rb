class RemoveUrlFromShippingLabels < ActiveRecord::Migration
  def up
    remove_column :mtg_transactions_shipping_labels, :url
  end
end
