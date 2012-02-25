class AddActiveToMtg < ActiveRecord::Migration
  def self.up
    add_column :mtg_cards, :active, :boolean, :default => true, :null => false
    add_column :mtg_sets, :active, :boolean, :default => false, :null => false
    add_column :mtg_blocks, :active, :boolean, :default => true, :null => false
    
    add_index :mtg_cards, :active
    add_index :mtg_sets, :active
    add_index :mtg_blocks, :active        
  end

  def self.down
    remove_column :mtg_cards, :active
    remove_column :mtg_sets, :active
    remove_column :mtg_blocks, :active        
  end
end


