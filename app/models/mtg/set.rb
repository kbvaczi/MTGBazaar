class Mtg::Set < ActiveRecord::Base
  self.table_name = 'mtg_sets'  
    
  has_many :cards, :class_name => "Mtg::Card", :foreign_key => "set_id"
  belongs_to :block, :class_name => "Mtg::Block"  
end
