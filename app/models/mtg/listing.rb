class Mtg::Listing < ActiveRecord::Base
  self.table_name = 'mtg_listings'    
  
  belongs_to :card, :class_name => "Mtg::Card"
  belongs_to :seller, :class_name => "User"
  belongs_to :transaction, :class_name => "Mtg::Transaction"
  belongs_to :cart
  
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
    self.cart_id == nil and self.active == true and self.sold_at == nil and self.transaction_id == nil and self.rejected_at == nil
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
  
  # used for searching for available listings... Mtg::Listing.available will return all available listings
  def self.available
    where(:cart_id => nil, :active => true, :sold_at => nil, :transaction_id => nil, :rejected_at => nil)
  end

  # returns listings that are in a shopping cart
  def self.reserved
    where("cart_id IS NOT NULL AND sold_at IS NULL AND transaction_id IS NULL AND rejected_at IS NULL")
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
      when /NM/ #contains "C" 
        return "Near-Mint"
      when /E/ #contains "U" 
        return "Excellent"
      when /F/ #contains "R" 
        return "Fine"
      when /G/ #contains "M" 
        return "Good"
      else return "Unknown"
    end
  end
end
