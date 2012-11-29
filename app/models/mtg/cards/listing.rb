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
  attr_accessible :name, :set, :quantity, :price, :condition, :language, :description, :altart,
                  :misprint, :foil, :signed, :price_options, :quantity_available, :scan, :scan_cache, :remove_scan

  # not-in-model field for current password confirmation
  attr_accessor :name, :set, :price_options

  # --------------------------------------- #
  # ------------ Callbacks ==-------------- #
  # --------------------------------------- #

  before_validation :set_quantity_available, :on => :create
  after_create      :update_statistics_cache_on_save
  after_save        :update_statistics_cache_on_save, :if => "active_changed? || price_changed? || quantity_available_changed?"
  after_save        :delete_if_empty
  before_destroy    :update_statistics_cache_on_delete
  
  def delete_if_empty
    self.destroy if quantity_available == 0 && quantity == 0 && reservations.count == 0
  end
  
  def set_quantity_available
    self.quantity_available = self.quantity
  end
  
  def update_statistics_cache_on_save
    self.card.statistics.listings_available(:overwrite => true)
    self.card.statistics.price_min(:overwrite => true) if self.price <= self.card.statistics.price_min || self.card.statistics.price_min == 0
  end
  
  def update_statistics_cache_on_delete
    self.card.statistics.listings_available(:overwrite => true) if self.card.statistics.present?
    self.card.statistics.price_min(:overwrite => true) if self.price <= self.card.statistics.price_min || self.card.statistics.price_min == 0 if self.card.statistics.present?
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

  def validate_scan
    errors[:scan] << "Max file size is 5MB" if scan.size > 5.megabytes
    errors[:quantity] << "Max quantity is 1 when attaching scan" if quantity > 1
  end
  
  def validate_options
    errors[:scan] << "Required for the options you have selected" if ( altart.present? || misprint.present? || signed.present? ) && !scan.present?    
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
                :scan => "")
      results = results.where("id <> ?", listing.id) unless include_self
      results # return results
    else
      return [] # this listing had a scan, it has no duplicates
    end
  end
  
  # returns the number of listings that are a duplicate of this listing in a subset if specified or in the entire database if subset not specified
  # this should be phased out
  def duplicate_listing_count(subset = nil, show_only_available = true)
    if subset
      relation_of_listings = subset
    else 
      relation_of_listings = Mtg::Cards::Listing.where(:seller_id => self.seller_id, :card_id => self.card_id)
    end
    #relation_of_listings.duplicate_listings_of(self, false, show_only_available).count
    count = 0
    relation_of_listings.each do |l|
      count += 1 if self.duplicate_listing?(l)
    end
    count #return count
  end
  
  # returns the number of listings that are a duplicate of this listing in a subset if specified or in the entire database if subset not specified
  def self.duplicate_listing_count(listing)
    duplicate_listings_of(listing).count
  end
  
  # organizes an activerecord relation of Mtg::Cards::Listings by duplicates 
  # in the form of [{"count" => count, "listing" => reference listing}, {"count" => count, "listing" => reference listing}]
  def self.organize_by_duplicates(show_only_available = true)
    array_of_listings = available if show_only_available
    array_of_listings = where("id <> 0") if not show_only_available
    array_of_duplicates = Array.new
    array_of_listings.each do |l|
      array_of_duplicates << {"count" => l.duplicate_listing_count(array_of_listings), "listing" => l}
      array_of_listings.delete_if {|x| x.duplicate_listing?(l) && x != l}
    end
    #inefficient code - array_of_duplicates.each {|d| array_of_duplicates.delete_if {|x| d["listing"].duplicate_listing?(x["listing"]) && d["listing"] != x["listing"] }}
    array_of_duplicates
  end
  
  # finds the first available listing that is duplicate to this one
  def find_duplicate_listing(subset = nil)
    if subset
      array_of_listings = subset
    else 
      array_of_listings = Mtg::Cards::Listing.where(:seller_id => self.seller_id, :card_id => self.card_id).available
    end
      
  end
end