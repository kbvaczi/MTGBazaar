class Mtg::Card < ActiveRecord::Base
  self.table_name = 'mtg_cards'  

  include Mtg::CardsHelper
  include ActionView::Helpers::NumberHelper  # needed for number_to_currency  

  belongs_to  :set,                         :class_name => "Mtg::Set"
  has_one     :block,     :through => :set, :class_name => "Mtg::Block",    :foreign_key => "block_id"
  has_many    :listings,                    :class_name => "Mtg::Listing",  :foreign_key => "card_id"
  
  # override default route to add username in route.
  def to_param
    "#{id}-#{display_name(name)}".parameterize
  end
  
  def dual_sided_card?
    return true if card_number.match(/[\d]+[aAbB]/).present?
    return false
  end
  
  def thumbnail_image_path
    return image_path.gsub(".jpg", "_thumb.jpg")
  end
  
  def listing_price_high
    return number_to_currency(1.50)
  end
  
  def listing_price_med
    return number_to_currency(1.30)
  end
  
  def listing_price_low
    return  number_to_currency(1.00)
  end
  
  def formatted_name
    return  name.truncate(30, :omission => "...")
  end
  
  # lists the available languages this card has
  def list_language_options
    return [["English","EN"], ["Russian","RU"], ["French","FR"], ["Japanese","JN"], ["Chinese","CN"], ["Korean","KO"], ["German","GN"], ["Portuguese", "PG"], ["Spanish", "SP"], ["Italian", "IT"]]
  end
end