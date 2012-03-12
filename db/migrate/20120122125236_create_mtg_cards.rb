class CreateMtgCards < ActiveRecord::Migration
  def up
    create_table :mtg_cards do |t|
      t.integer  :set_id    #foreign key for sets

      t.string   :name,                      :default => "", :null => false
      t.string   :card_type,                 :default => "", :null => false
      t.string   :card_subtype,              :default => "", :null => false
      t.string   :rarity,                    :default => "", :null => false
      t.string   :artist,                    :default => "", :null => false
      t.text     :description,               :default => "", :null => false
      t.string   :mana_string,               :default => "", :null => false
      t.string   :mana_color,                :default => "", :null => false
      t.string   :mana_cost,                 :default => "", :null => false
      t.string   :power,                     :default => "", :null => false
      t.string   :toughness,                 :default => "", :null => false
      #t.string   :legality_block,            :default => "", :null => false
      #t.string   :legality_standard,         :default => "", :null => false
      #t.string   :legality_extended,         :default => "", :null => false
      #t.string   :legality_modern,           :default => "", :null => false
      #t.string   :legality_legacy,           :default => "", :null => false
      #t.string   :legality_vintage,          :default => "", :null => false
      #t.string   :legality_highlander,       :default => "", :null => false
      #t.string   :legality_french_commander, :default => "", :null => false
      #t.string   :legality_commander,        :default => "", :null => false
      #t.string   :legality_peasant,          :default => "", :null => false
      #t.string   :legality_pauper,           :default => "", :null => false

      t.string   :multiverse_id,             :default => "", :null => false
      t.string   :image_path,                :default => "", :null => false
      t.string   :image_back_path,           :default => "", :null => false

      t.timestamps
    end
    
    # Indexes go here.  This table is heavily indexed to be fast searching, but slow to read/write
    
    add_index :mtg_cards , :artist
    add_index :mtg_cards , :mana_color
    add_index :mtg_cards , :name
    add_index :mtg_cards , :rarity
    add_index :mtg_cards , :set_id
    add_index :mtg_cards , :card_type
    add_index :mtg_cards , :card_subtype    

  end
  
  def down
    drop_table :mtg_cards
  end
end


