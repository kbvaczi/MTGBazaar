class Mtg::Cards::Ability < ActiveRecord::Base
  self.table_name = 'mtg_cards_abilities'  
  
  validates_presence_of :name
  
end
