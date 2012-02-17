class AddNumberToMtgCards < ActiveRecord::Migration
  def self.up
    add_column :mtg_cards, :card_number, :string 
  end

  def self.down
    remove_column :mtg_cards, :card_number
  end
end
