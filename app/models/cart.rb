class Cart < ActiveRecord::Base

  belongs_to  :user
  has_many    :reservations, :class_name => "Mtg::Reservation", :dependent => :destroy
  has_many    :listings, :class_name => "Mtg::Listing" , :through => :reservations, :foreign_key => "listing_id"
  
  # Implement Money gem for total_price column
  composed_of   :total_price,
                :class_name => 'Money',
                :mapping => %w(total_price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  

  attr_accessible :user_id, :total_price, :item_count
  
  validates_presence_of   :user
  validates :total_price, :numericality => {:greater_than => 0, :less_than => 10000000}  #quantity must be between 0 and $100,000
  validates :item_count,  :numericality => {:greater_than => 0, :less_than => 10000}  #quantity must be between 0 and 10,000
                    
  def add_mtg_listing(listing, quantity = 1)
    #if listing.quantity_available >= quantity && quantity > 0 # check to make sure there are enough cards available in the listing
      if self.listings.include?(listing) # is there already a reservation for this listing in cart?
        res = self.reservations.where(:listing_id => listing.id).first.increment(:quantity, quantity) # add to existing reservation
      else
        res = self.reservations.new(:listing_id => listing.id, :quantity => quantity) # build a new reservation
      end
      res.listing.decrement(:quantity_available, quantity)
      if res.save
        self.update_cache! # update item count and price
        return true # success
      else
        return false # fail
      end
  end

  def remove_mtg_listing(reservation, quantity = 1)
    if reservation.cart.id == self.id && quantity > 0 #check to make sure reservation is actually in this cart
      if quantity < reservation.quantity # remove less quantity than reservation holds, just update quantity in reservation
        reservation.decrement(:quantity, quantity).save
        reservation.listing.increment(:quantity_available, quantity).save
      elsif quantity == reservation.quantity # remove reservation completely
        if reservation.destroy  
          reservation.listing.increment(:quantity_available, quantity).save # keep track of listing available quantity
        end
      end
      self.update_cache! # update item count and price              
      return true # success 
    end
    return false # fail
  end  
  
  def update_cache!
    reservations = Mtg::Reservation.where(:cart_id => self.id).joins(:listing)
    self.item_count = reservations.sum("mtg_reservations.quantity")
    self.total_price = reservations.sum("mtg_listings.price * mtg_reservations.quantity").to_f / 100
    self.save
  end

  def empty!
    self.reservations.each {|r| self.remove_mtg_listing(r,r.quantity)}
  end  

   def mtg_listing_ids   #returns array of ids of mtg_listings in cart
     self.listings.collect { |l| l.id }
   end

   def seller_ids        #creates a unique list of seller ids
     self.listings.collect { |l| l.seller_id }.uniq
   end

   def mtg_listings_for_seller_id(id)
     self.listings.where(:seller_id => id)
   end
   
end
