class Mtg::Listing < ActiveRecord::Base
  self.table_name = 'mtg_listings'    
  
  belongs_to :card, :class_name => "Mtg::Card"
  belongs_to :seller, :class_name => "User"
  belongs_to :transaction, :class_name => "Mtg::Transaction"
  
  # Implement Money gem for price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name,  :set, :quantity, :price, :condition, :language, :description, 
                          :foreign, :defect, :foil, :signed, :price_options, :price_other

  # not-in-model field for current password confirmation
  attr_accessor :name, :set, :quantity, :price_options, :price_other
  
  # validations
  validates_presence_of :price, :condition, :language
  
  # determins if listing is available to be added to cart (active, not already in cart, and not already sold)
  def available?
    self.reserved == false and self.active == true and self.sold_at == nil and self.transaction_id == nil
  end
  
  # mark a listing as reserved (added to a cart)
  def reserve!
    self.update_attribute(:reserved, true)
  end

  # mark a listing as NOT reserved (removed from a cart)
  def free!
    self.update_attribute(:reserved, false)
  end  
  
  # used for searching for available listings... Mtg::Listing.available will return all available listings
  def self.available
    where(:reserved => false, :active => true, :sold_at => nil, :transaction_id => nil)
  end
  
  # used for searching for active listings...
  def self.active
    where(:active => true, :sold_at => nil, :transaction_id => nil)
  end
  
  # used for searching for inactive listings...
  def self.inactive
    where(:active => false, :sold_at => nil, :transaction_id => nil)
  end
  
  # used for searching listings by seller...  Mtg::Listing.by_seller_id([2,3]) will return all listings from seller 2 and 3
  def self.by_seller_id(id)
    where(:seller_id => id )
  end
  
  # used for searching listings by seller...  Mtg::Listing.by_seller_id([2,3]) will return all listings from seller 2 and 3
  def self.by_id(id)
    where(:id => id )
  end  
  
end
