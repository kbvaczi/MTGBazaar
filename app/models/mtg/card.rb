class Mtg::Card < ActiveRecord::Base
  self.table_name = 'mtg_cards'  

  include Mtg::CardsHelper   # include ActionView::Helpers::AssetTagHelper

  
  belongs_to  :set,                         :class_name => "Mtg::Set"
  has_one     :block,     :through => :set, :class_name => "Mtg::Block",    :foreign_key => "block_id"
  has_many    :listings,                    :class_name => "Mtg::Listing",  :foreign_key => "card_id"
  
  # override default route to add username in route.
  def to_param
    "#{id}-#{display_name(name)}".parameterize
  end
  
end