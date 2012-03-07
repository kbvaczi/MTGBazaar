class Mtg::Block < ActiveRecord::Base
  self.table_name = 'mtg_blocks'  
  
  has_many :sets, :class_name => "Mtg::Set", :foreign_key => "block_id"
  has_many :cards, :through => :sets, :class_name => "Mtg::Card", :foreign_key => "set_id"
end
