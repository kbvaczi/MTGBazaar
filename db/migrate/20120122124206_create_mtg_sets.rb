class CreateMtgSets < ActiveRecord::Migration
  
  def up
    create_table :mtg_sets do |t|
      
      #foreign keys
      t.integer  :block_id
      
      t.string   :name           , :default => ""          , :null => false 
      t.string   :symbol         , :default => ""          , :null => false 
      t.datetime :release_date   , :default => Time.now()  , :null => false
      
      t.timestamps
    end
    
    # any indexes go here
    add_index :mtg_sets, :name,               :unique => true
    add_index :mtg_sets, :symbol,             :unique => true
    add_index :mtg_sets, :release_date
  
  end
  
  def down
    drop_table :mtg_sets
  end
  
end

