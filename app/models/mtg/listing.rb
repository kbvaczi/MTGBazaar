class Mtg::Listing < ActiveRecord::Base
  self.table_name = 'mtg_listings'    
  
  belongs_to :card,         :class_name => "Mtg::Card"
  belongs_to :seller,       :class_name => "User"
  belongs_to :transaction,  :class_name => "Mtg::Transaction"
  has_many   :reservations, :class_name => "Mtg::Reservation"
  has_many   :carts,        :through => :reservations
  mount_uploader :scan, MtgScanUploader
  
  # Implement Money gem for price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :set, :quantity, :price, :condition, :language, :description, :altart,
                  :misprint, :foil, :signed, :price_options, :quantity_available, :scan

  # not-in-model field for current password confirmation
  attr_accessor :name, :set, :price_options
  
  # validations
  validates_presence_of :price, :condition, :language, :quantity
  validates :quantity, :numericality => {:greater_than => 0, :less_than => 10000}  #quantity must be between 0 and 10000
  validates :price, :numericality => {:greater_than => 0, :less_than => 1000000, :message => "Must be between $0.01 and $10,000"}   #price must be between $0 and $10,000.00
  validate  :validate_scan, :if => "scan?"  

  def validate_scan
    errors[:scan] << "Max file size is 5MB" if scan.size > 5.megabytes
    errors[:quantity] << "Max quantity is 1 when attaching scan" if quantity > 1
  end
  
  before_create do      # all cards are available when created
    self.quantity_available = self.quantity
  end
  
  def quantity_reserved
    self.quantity - self.quantity_available
  end
  
  # determines if listing is available to be added to cart (active, not already in cart, and not already sold)
  def available?
    self.cart_id == nil and self.active == true and self.sold_at == nil and self.transaction_id == nil and self.rejected_at == nil and self.quantity_available > 0
  end
  
  def active?
    self.active == true
  end
  
  # used for searching for available listings... Mtg::Listing.available will return all available listings
  def self.available
    where(:cart_id => nil, :active => true, :sold_at => nil, :transaction_id => nil, :rejected_at => nil).where("quantity_available > 0")
  end
  
  def in_cart?
    not (self.quantity_available == self.quantity and quantity_available > 0)
  end
  
  # mark a listing as reserved (added to a cart)
  def reserve!
    self.update_attribute(:cart_id, current_cart.id)
  end

  # mark a listing as NOT reserved (removed from a cart and transaction)
  def free!
    self.cart_id = nil
    self.transaction_id = nil
    self.sold_at = nil    
    self.save(:validate => false)
  end
  
  # mark a listing as sold
  def mark_as_sold!(transaction_id)
    self.sold_at = Time.now
    self.transaction_id = transaction_id
    self.save(:validate => false)
  end

  # mark a listing as NOT sold
  def mark_as_unsold!
    self.update_attribute(:sold_at, nil)
  end  

  # mark this listing as rejected which permenantly removes it from user view
  def mark_as_rejected!
    self.update_attribute(:rejected_at, Time.now)
    self.update_attribute(:active, false)    
  end  
  
  def mark_as_active!
    self.update_attribute(:active, true)    
  end
  
  def mark_as_inactive!
    self.update_attribute(:active, false)    
  end
  
  # returns listings that are in a shopping cart
  def self.reserved
    where("cart_id IS NOT NULL")
  end  

  # used for searching for available listings... Mtg::Listing.sold will return all available listings
  def self.sold
    where("sold_at IS NOT NULL AND rejected_at IS NULL")
  end  
  
  # searches for rejected listings.  Rejected listings are dummy placeholders for tracking rejected transactions... users cannot see rejected listings
  def self.rejected
    where("rejected_at IS NOT NULL")
  end  
  
  # used for searching for active listings...
  def self.active
    where(:active => true, :sold_at => nil, :transaction_id => nil, :rejected_at => nil)
  end
  
  # used for searching for inactive listings...
  def self.inactive
    where(:active => false, :sold_at => nil, :transaction_id => nil, :rejected_at => nil)
  end
  
  # used for searching listings by seller...  Mtg::Listing.by_seller_id([2,3]) will return all listings from seller 2 and 3
  def self.by_seller_id(id)
    where(:seller_id => id )
  end
  
  # used for searching listings by seller...  Mtg::Listing.by_seller_id([2,3]) will return all listings from seller 2 and 3
  def self.by_id(id)
    where(:id => id )
  end  
  
  def formatted_condition
    case self.condition
      when /1/ 
        return "NM"
      when /2/ 
        return "EX"
      when /3/ 
        return "FN"
      when /4/ 
        return "GD"
      else return "Unknown"
    end
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
      relation_of_listings = Mtg::Listing.where(:seller_id => self.seller_id, :card_id => self.card_id)
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
  
  # organizes an activerecord relation of Mtg::Listings by duplicates 
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
      array_of_listings = Mtg::Listing.where(:seller_id => self.seller_id, :card_id => self.card_id).available
    end
      
  end
end