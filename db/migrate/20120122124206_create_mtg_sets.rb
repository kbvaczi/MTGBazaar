class CreateMtgSets < ActiveRecord::Migration
  
  def up
    
    create_table :mtg_sets do |t|
      
      #foreign keys
      t.integer  :block_id
      
      t.string   :name           , :default => ""          , :null => false 
      t.string   :code           , :default => ""          , :null => false 
      t.date     :release_date   , :default => Time.now()
      
      t.timestamps
      
    end
    
    # any indexes go here
    add_index :mtg_sets, :name
    add_index :mtg_sets, :code
    add_index :mtg_sets, :release_date
  
  end
  
  def down
    
    drop_table :mtg_sets
    
  end
  
end

