class MtgBlock < ActiveRecord::Base
  has_many :sets, :class_name => "MtgSet", :foreign_key => "block_id"
  has_many :cards, :through => :sets, :class_name => "MtgCard", :foreign_key => "set_id"
end
