class CreateShippingLabels < ActiveRecord::Migration
  def up
    create_table :mtg_transactions_shipping_labels do |t|
      #foreign keys(none)      
      t.integer   :transaction_id
      
      #table data
      t.string    :url      # url to fetch postage from stamps.com
      t.string    :stamps_tx_id # used for tracking
      t.integer   :price    # total postage price

      t.string    :params   # raw data coming back from stamps.com
      t.timestamps
      
    end
    
    #indexes
    add_index :mtg_transactions_shipping_labels, :transaction_id
      
  end
  
  def down
    drop_table :mtg_transactions_shipping_labels
    
  end

end
