class AddValueAndShippingToTransactions < ActiveRecord::Migration
  def up
    add_column :mtg_transactions, :value, :integer
    add_column :mtg_transactions, :shipping_cost, :integer    
    
    create_table :mtg_transaction_payments do |t|
      #foreign keys      
      t.integer   :user_id
      t.integer   :transaction_id      
      #table data
      t.integer   :price
      t.string    :status,          :default => "active"
      t.timestamps
    end
    
    #indexes
    add_index :mtg_transaction_payments, :user_id
    add_index :mtg_transaction_payments, :transaction_id
    
    create_table :mtg_transaction_credits do |t|
      #foreign keys      
      t.integer   :user_id
      t.integer   :transaction_id      
      #table data
      t.integer   :price
      t.integer   :commission
      t.float     :commission_rate, :default => nil
      t.string    :status,          :default => "active"
      t.timestamps
    end

    #indexes
    add_index :mtg_transaction_credits, :user_id
    add_index :mtg_transaction_credits, :transaction_id
  end
  
  def down
    remove_column :mtg_transactions, :value
    remove_column :mtg_transactions, :shipping_cost
    
    drop_table :mtg_transaction_payments if ActiveRecord::Base.connection.table_exists? 'mtg_transaction_payments' 
    drop_table :mtg_transaction_credits  if ActiveRecord::Base.connection.table_exists? 'mtg_transaction_credits' 
  end
end
