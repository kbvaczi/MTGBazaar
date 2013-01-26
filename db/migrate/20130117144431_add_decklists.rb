class AddDecklists < ActiveRecord::Migration
  def up
    
    unless table_exists? :mtg_decklists
      create_table  :mtg_decklists do |t|
        #foreign keys
        
        #table data
        t.string    :name
        t.string    :mana_string
        t.string    :play_format
        t.string    :event        
        t.boolean   :active
        
        t.timestamps
      end
    end
    
    unless table_exists? :mtg_decklists_card_references
      create_table  :mtg_decklists_card_references do |t|
        #foreign keys      
        t.integer   :decklist_id
        t.integer   :card_id
        t.string    :card_name
        #table data
        t.string    :deck_section
        t.string    :deck_subsection
        t.integer   :quantity
        
        t.timestamps      
      end
      add_index :mtg_decklists_card_references, :decklist_id
      add_index :mtg_decklists_card_references, :card_id
      add_index :mtg_decklists_card_references, :card_name
    end
  end

  def down
    drop_table    :mtg_decklists if table_exists? :mtg_decklists
    drop_table    :mtg_decklists_card_references if table_exists? :mtg_decklists_card_references
  end
end
