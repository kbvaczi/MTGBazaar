class MtgCard < ActiveRecord::Base
  belongs_to :set, :class_name => "MtgSet"
  
end