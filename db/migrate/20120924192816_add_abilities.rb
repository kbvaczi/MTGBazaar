class AddAbilities < ActiveRecord::Migration
  def up
    create_table :mtg_cards_abilities do |t|
      t.string    :name,           :default => ""
    end
  end
  
  def down
    drop_table :mtg_cards_abilities
  end
end

