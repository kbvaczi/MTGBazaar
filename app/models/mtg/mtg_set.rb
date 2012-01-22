class MtgSet < ActiveRecord::Base
  has_many :cards, :class_name => "MtgCard", :foreign_key => "set_id"
  
end
