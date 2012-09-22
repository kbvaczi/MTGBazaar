class CreateShippingLabels < ActiveRecord::Migration
  def up
    create_table :mtg_transactions_shipping_labels do |t|
      #foreign keys(none)      
      t.integer   :transaction_id
      
      #table data
      t.string    :stamps_tx_id # used for tracking
      t.integer   :price        # total postage price paid by MTGBazaar to stamps.com
      t.string    :status       , :default => "active" # active, or refunded?

      t.text      :params       # raw data coming back from stamps.create
      t.text      :tracking     # raw data coming back from stamps.track
      t.text      :refund       # raw data coming back from stamps.refund
      
      t.timestamps
      
    end
    
    #indexes
    add_index :mtg_transactions_shipping_labels, :transaction_id, :name => "shipping_labels_transactions_id"
      
  end
  
  def down
    drop_table :mtg_transactions_shipping_labels
    
  end

end
