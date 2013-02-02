class Mtg::Cards::Listing < ActiveRecord::Base
  self.table_name = 'mtg_listings'    
  
  belongs_to :card,         :class_name => "Mtg::Card"
  belongs_to :seller,       :class_name => "User"
  has_one    :statistics,   :class_name => "Mtg::Cards::Statistics",   :through => :card
  has_many   :reservations, :class_name => "Mtg::Reservation",      :dependent => :destroy
  has_many   :orders,       :class_name => "Mtg::Order",            :through => :reservations,      :foreign_key => :order_id  
  has_many   :carts,        :class_name => "Cart",                  :through => :reservations,      :source => :cart
  
  mount_uploader :scan, MtgScanUploader
  
  # Implement Money gem for price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :set, :quantity, :price, :condition, :language, :description, :altart, :playset,
                  :misprint, :foil, :signed, :price_options, :quantity_available, :scan, :scan_cache, :remove_scan

  # not-in-model field for current password confirmation
  attr_accessor :name, :set, :price_options, :no_cache_update, :rarity

  # --------------------------------------- #
  # ------------ Callbacks ==-------------- #
  # --------------------------------------- #

  before_validation :set_quantity_available, :on => :create
  after_save       :update_statistics_cache_on_save, :if => "no_cache_update != false && (active_changed? || price_changed? || quantity_available_changed? || self.price == Money.new(100))"
  after_save        :delete_if_empty
  after_destroy     :update_statistics_cache_on_delete, :if => "no_cache_update != false"
  
  def delete_if_empty
    self.destroy if quantity_available == 0 && quantity == 0 && reservations.count == 0
  end
  
  def set_quantity_available
    self.quantity_available = self.quantity
  end
  
  def update_statistics_cache_on_save
    my_card_statistics   = Mtg::Cards::Statistics.where(:card_id => self.card_id).first
    my_seller_statistics = UserStatistics.where(:user_id => self.seller_id).first
    if self.new_record?
      #self.card.statistics.update_attribute(:listings_available, self.card.statistics.listings_available + (self.quantity_available * self.number_cards_per_item))
      my_card_statistics.listings_available(true) if my_card_statistics.present?
      #self.seller.statistics.update_attribute(:listings_mtg_cards_count, (self.seller.statistics.listings_mtg_cards_count || 0) + self.quantity_available * self.number_cards_per_item)      
      my_seller_statistics.listings_mtg_cards_count(true) if my_seller_statistics.present?
    else
      #self.card.statistics.update_attribute(:listings_available, self.card.statistics.listings_available + (self.quantity_available - self.quantity_available_was) * self.number_cards_per_item)
      my_card_statistics.listings_available(true) if my_card_statistics.present?
      #self.seller.statistics.update_attribute(:listings_mtg_cards_count, self.seller.statistics.listings_mtg_cards_count + (self.quantity_available - self.quantity_available_was) * self.number_cards_per_item)
      my_seller_statistics.listings_mtg_cards_count(true) if my_seller_statistics.present?
    end
    my_card_statistics.update_attribute(:price_min, self.price) if my_card_statistics.present? && ((self.price < my_card_statistics.price_min) || (self.price_changed? && (Money.new(self.price_was) <= my_card_statistics.price_min)) || (my_card_statistics.price_min == 0))
  end
  
  def update_statistics_cache_on_delete
    self.card.statistics.update_attribute(:listings_available, self.card.statistics.listings_available - self.quantity_available) if self.card.statistics.present?
    self.card.statistics.price_min(true) if self.card.statistics.present? && (self.price <= self.card.statistics.price_min || self.card.statistics.price_min == 0)
    self.seller.statistics.update_attribute(:listings_mtg_cards_count, self.seller.statistics.listings_mtg_cards_count - (self.quantity_available * self.number_cards_per_item))
  end
  
  # --------------------------------------- #
  # ------------ Validations -------------- #
  # --------------------------------------- #

  validates_presence_of :price, :condition, :language, :quantity
  validates :quantity,            :numericality => {:greater_than => 0,             :less_than => 10000}, :on => :create  # quantity must be between 1 and 10000 when creating (we do not create empty listings)
  validates :quantity,            :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}, :on => :update  # we will allow 0 quantity on update, we will destroy this listing after save, however.
  validates :quantity_available,  :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}                 # quantity_available must be between 0 and 10000  
  validates :price,               :numericality => {:greater_than => 0,             :less_than => 1000000, :message => "Must be between $0.01 and $10,000"}   #price must be between $0 and $10,000.00
  validates :description,         :length => {:maximum => 255}
  validate  :validate_scan, :if => "scan?"
  validate  :validate_options # scan must be included if options are selected
  validate  :validate_playset, :if => "self.playset"

  def validate_scan
    errors[:scan] << "Max file size is 5MB" if scan.size > 5.megabytes
    errors[:quantity] << "Max quantity is 1 when attaching scan" if quantity > 1
  end
  
  def validate_options
    errors[:scan] << "Required for the options you have selected" if ( altart.present? || misprint.present? || signed.present? ) && !scan.present?    
  end
  
  def validate_playset
    errors[:quantity] << "number of cards per playset must be 4, please contact administrator" if self.number_cards_per_item != 4
    #errors[:scan]     << "Cannot have scan with playsets"           if self.scan.present?
    #errors[:altart]   << "Cannot have altered cards in playsets"    if self.altart
    #errors[:misprint] << "Cannot have misprinted cards in playsets" if self.misprint
    #errors[:signed]   << "Cannot have signed cards in playsets"     if self.signed    
  end

  # ------------ Universal Product Methods --------- #
  
  def product_name
    output_string = ""
    output_string += "Playset:<br/>" if self.playset
    output_string += self.card.name
  end

  def product_recommended_pricing(options = {:condition => (self.condition rescue "1")})
    statistics = self.card.statistics
    pricing_hash = {:price_low => statistics.price_low, :price_med => statistics.price_med, :price_high => statistics.price_high }
    pricing_hash.each { |k,v| pricing_hash[k] = v * 4 } if self.playset
    case options[:condition]
      when "2"
        return pricing_hash.each { |k,v| pricing_hash[k] = v * 0.95 }
      when "3"
        return pricing_hash.each { |k,v| pricing_hash[k] = v * 0.85 }
      when "4"      
        return pricing_hash.each { |k,v| pricing_hash[k] = v * 0.75 }
      else
        return pricing_hash
    end
  end

  # --------------------------------------- #
  # ------------ Public Model Methods ----- #
  # --------------------------------------- #
  
  def quantity_reserved
    self.quantity - self.quantity_available
  end
  
  # determines if listing is available to be added to cart (active, not already in cart, and not already sold)
  def available?
    self.active == true and self.quantity_available > 0
  end
  
  def active?
    self.active == true
  end
  
  def in_cart?
    not (self.quantity_available == self.quantity and self.quantity_available > 0)
  end
    
  def mark_as_active!
    self.update_attribute(:active, true)    
  end
  
  def mark_as_inactive!
    self.update_attribute(:active, false)    
  end
    
  # used for searching for active listings...
  def self.active
    joins(:seller).where(:active => true, "users.active" => true, "users.banned" => false, "users.locked_at" => nil)
  end
  
  # used for searching for inactive listings...
  def self.inactive
    joins(:seller).where("mtg_listings.active LIKE ? OR users.active LIKE ?", false, false)
  end

  # used for searching for available listings... Mtg::Cards::Listing.available will return all available listings
  def self.available
    where("quantity_available > 0").active
  end
    
  # used for searching listings by seller...  Mtg::Cards::Listing.by_seller_id([2,3]) will return all listings from seller 2 and 3
  def self.by_seller_id(id)
    where(:seller_id => id )
  end
  
  # used for searching listings by seller...  Mtg::Cards::Listing.by_seller_id([2,3]) will return all listings from seller 2 and 3
  def self.by_id(id)
    where(:id => id )
  end  
  
  # returns true if other_listing is a duplicate listing to this listing otherwise returns false
  def duplicate_listing?(other_listing)
    return true if self.seller_id == other_listing.seller_id && 
                   self.card_id == other_listing.card_id &&                    
                   self.price == other_listing.price &&
                   self.condition == other_listing.condition &&
                   self.language == other_listing.language &&
                   self.foil == other_listing.foil &&
                   self.misprint == other_listing.misprint &&
                   self.altart == other_listing.altart &&                   
                   self.signed == other_listing.signed &&
                   self.description == other_listing.description &&
                   self.playset == other_listing.playset &&                   
                   (not self.scan.present?) &&
                   (not other_listing.scan.present?)
    return false
  end
  
  # returns true if other_listing is a duplicate listing to this listing otherwise returns false
  def self.duplicate_listings_of(listing, include_self = true)
    unless listing.scan.present? # if listing has a scan, by definition it is unique and has no duplicates
      results = where(:seller_id => listing.seller_id,
                :card_id => listing.card_id)
                .where(:price => listing.price,
                :condition => listing.condition,
                :language => listing.language,
                :foil => listing.foil,
                :misprint => listing.misprint,
                :altart => listing.altart,
                :signed => listing.signed,
                :description => listing.description,
                :playset => listing.playset,                
                :scan => "")
      results = results.where("id <> ?", listing.id) unless include_self
      results # return results
    else
      return [] # this listing had a scan, it has no duplicates
    end
  end
  
end