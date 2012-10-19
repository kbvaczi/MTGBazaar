class CreateMtgTransactionItems < ActiveRecord::Migration
  def up
    create_table :mtg_transaction_items do |t|
      #foreign keys      
      t.integer   :card_id
      t.integer   :seller_id
      t.integer   :buyer_id      
      t.integer   :transaction_id


      t.integer   :price,                 :default => 100,            :null => false
      t.integer   :quantity,              :default => 1,              :null => false
      t.string    :condition,             :default => "1",            :null => false
      t.string    :language,              :default => "EN",           :null => false
      t.string    :description,           :default => "",             :null => false
      t.boolean   :signed,                :default => false,          :null => false
      t.boolean   :misprint,              :default => false,          :null => false
      t.boolean   :foil,                  :default => false,          :null => false
      t.boolean   :altart,                :default => false,          :null => false
          
      t.datetime  :rejected_at,           :default => nil
      
      t.timestamps
    end
    
    # Table Indexes
    add_index :mtg_transaction_items, :card_id
    add_index :mtg_transaction_items, :seller_id
    add_index :mtg_transaction_items, :buyer_id  
    add_index :mtg_transaction_items, :transaction_id
                        
  end
  
  def down
    drop_table :mtg_transaction_items
  end
end
