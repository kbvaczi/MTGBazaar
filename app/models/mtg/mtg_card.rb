class MtgCard < ActiveRecord::Base
  #belongs_to :set, :class_name => "MtgSet"
  #has_one :block, :through => :set, :class_name => "MtgBlock", :foreign_key => "block_id"
end