class CreateMtgListings < ActiveRecord::Migration
  def up
    create_table :mtg_listings do |t|
      #foreign keys      
      t.integer   :card_id
      t.integer   :seller_id

      t.integer   :price,         :default => 100      
      t.string    :condition,     :default => "NM"
      t.string    :language,      :default => "english"
      t.string    :description,   :default => ""
      t.boolean   :foreign,       :default => false
      t.boolean   :defect,        :default => false
      t.boolean   :foil,          :default => false
      t.boolean   :sold,          :default => false
      t.boolean   :reserved,      :default => false
      t.boolean   :active,        :default => true

      t.timestamps
    end
    
    # Table Indexes
    add_index :mtg_listings, :card_id
    add_index :mtg_listings, :seller_id
    
    add_index :mtg_listings, :condition
    add_index :mtg_listings, :foil
    add_index :mtg_listings, :defect
    add_index :mtg_listings, :sold
    add_index :mtg_listings, :reserved
    add_index :mtg_listings, :active
    add_index :mtg_listings, :foreign    
                        
  end
  
  def down
    drop_table :mtg_listings
  end
end
