class MtgCard < ActiveRecord::Base
  include MtgCardsHelper   # include ActionView::Helpers::AssetTagHelper

  
  belongs_to  :set,                         :class_name => "MtgSet"
  has_one     :block,     :through => :set, :class_name => "MtgBlock",    :foreign_key => "block_id"
  has_many    :listings,                    :class_name => "MtgListing",  :foreign_key => "card_id"
  
  # override default route to add username in route.
  def to_param
    "#{id}-#{display_name(name)}".parameterize
  end
  
end