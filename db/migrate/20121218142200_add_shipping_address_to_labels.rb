class AddShippingAddressToLabels < ActiveRecord::Migration
    def up
      add_column(:mtg_transactions_shipping_labels, :to_address,   :text)     unless column_exists?(:mtg_transactions_shipping_labels, :to_address)
      add_column(:mtg_transactions_shipping_labels, :from_address, :text)     unless column_exists?(:mtg_transactions_shipping_labels, :from_address)      
    end

    def down
      remove_column(:mtg_transactions_shipping_labels, :to_address)       if column_exists?(:mtg_transactions_shipping_labels, :to_address)                    
      remove_column(:mtg_transactions_shipping_labels, :from_address)     if column_exists?(:mtg_transactions_shipping_labels, :from_address)                          
    end

end
