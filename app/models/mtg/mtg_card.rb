class MtgCard < ActiveRecord::Base
  include MtgCardsHelper
  #include ActionView::Helpers::AssetTagHelper
  
  belongs_to :set, :class_name => "MtgSet"
  has_one :block, :through => :set, :class_name => "MtgBlock", :foreign_key => "block_id"
  
  
  # override default route to add username in route.
  def to_param
    "#{id}-#{display_name(name)}".parameterize
  end
  
  def autocomplete_name_display
    return "#{display_name(name)} #{mana_string}"
  end
  
end