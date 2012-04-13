class CreateMtgListings < ActiveRecord::Migration
  def up
    create_table :mtg_listings do |t|
      #foreign keys      
      t.integer   :card_id
      t.integer   :seller_id
      t.integer   :transaction_id
      t.integer   :cart_id

      t.integer   :price,         :default => 100,            :null => false
      t.string    :condition,     :default => "NM",           :null => false
      t.string    :language,      :default => "EN",           :null => false
      t.string    :description,   :default => "",             :null => false
      t.boolean   :signed,        :default => false,          :null => false
      t.boolean   :defect,        :default => false,          :null => false
      t.boolean   :foil,          :default => false,          :null => false
      
      t.boolean   :reserved,      :default => false,          :null => false
      t.boolean   :active,        :default => true,           :null => false
      t.datetime  :sold_at,       :default => nil      
      t.datetime  :rejected_at,   :default => nil
      
      t.timestamps
    end
    
    # Table Indexes
    add_index :mtg_listings, :card_id
    add_index :mtg_listings, :seller_id
    add_index :mtg_listings, :transaction_id
    add_index :mtg_listings, :cart_id
                        
  end
  
  def down
    drop_table :mtg_listings
  end
end
