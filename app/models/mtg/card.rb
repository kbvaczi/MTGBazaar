class Mtg::Card < ActiveRecord::Base
  self.table_name = 'mtg_cards'  

  include Mtg::CardsHelper
  include ActionView::Helpers::NumberHelper  # needed for number_to_currency  

  belongs_to  :set,                         :class_name => "Mtg::Set"
  has_one     :statistics,                  :class_name => "Mtg::CardStatistics",   :foreign_key => "card_id"
  has_one     :block,     :through => :set, :class_name => "Mtg::Block",            :foreign_key => "block_id"
  has_many    :listings,                    :class_name => "Mtg::Listing",          :foreign_key => "card_id"
  has_many    :sales,                       :class_name => "Mtg::TransactionItem",  :foreign_key => "card_id"  

  after_create :create_card_statistics
  
  # every new card gets a statistics model upon creation
  def create_card_statistics
    self.statistics = Mtg::CardStatistics.new
    #set pricing upon card creation if pricing exists
    self.statistics.price_low = self.price_low if self.price_low
    self.statistics.price_med = self.price_med if self.price_med    
    self.statistics.price_high = self.price_high if self.price_high 
    self.statistics.save   
  end

  validates_presence_of :set_id, :name, :card_type, :rarity, :artist, :description, :mana_string, :mana_color, :mana_cost, :image_path
  
  # allows card objects to take these inputs upon creation, even though they won't be stored under the card model itself.
  # these will be used to import prices into separate card statistics model
  attr_accessor :price_low, :price_med, :price_high
  
  # override default route to add username in route.
  def to_param
    "#{id}-#{display_name(name)}".parameterize
  end
  
# **************** CLASS METHODS ***************** #
  
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