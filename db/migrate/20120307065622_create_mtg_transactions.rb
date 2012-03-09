class CreateMtgTransactions < ActiveRecord::Migration
  def up
    create_table :mtg_transactions do |t|
      #foreign keys
      t.integer   :buyer_id
      t.integer   :seller_id
      t.integer   :cart_id

      t.datetime  :buyer_confirmed
      t.datetime  :seller_confirmed
      t.datetime  :seller_shipped
      t.string    :seller_tracking_number,    :default => "",           :null => false
      t.datetime  :seller_delivered
      t.boolean   :final,                     :default => false,        :null => false
      
      t.timestamps
    end

    # Table Indexes
    add_index :mtg_transactions, :buyer_id
    add_index :mtg_transactions, :seller_id
    add_index :mtg_transactions, :cart_id    

  end

  def down
    drop_table :mtg_transactions
  end
end