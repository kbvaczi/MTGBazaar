class Cart < ActiveRecord::Base
  
  has_many :mtg_listings, :class_name => "Mtg::Listing"  
  
  # Implement Money gem for total_price column
  composed_of   :total_price,
                :class_name => 'Money',
                :mapping => %w(total_price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
                    
  def add_mtg_listing(listing)
    if listing.cart_id.present? #check to make sure listing isn't already in a cart
      return false
    else
      self.mtg_listings.push(listing) # reserve this listing so nobody else can add it
      self.total_price += listing.price # keep track of cart's total price
      self.item_count += 1 # keep track of cart's item count
      self.save!
      return true # success
    end
  end

  def remove_mtg_listing(listing)
    if listing.cart_id == self.id #check to make sure listing is actually in this cart
      self.mtg_listings.delete(listing) # make this listing available to others to buy
      self.total_price -= listing.price # keep track of cart's total price
      self.item_count -= 1 # keep track of cart's item count    
      self.save! 
      return true # success      
    else
      return false
    end
  end  

   def mtg_listing_ids   #returns array of ids of mtg_listings in cart
     self.mtg_listings.collect { |l| l.id }
   end

   def seller_ids        #creates a unique list of seller ids
     self.mtg_listings.collect { |l| l.seller_id }.uniq
   end

   def mtg_listings_for_seller_id(id)
     self.mtg_listings.where(:seller_id => id)
   end

   def empty!            #removes all listings from cart
     self.mtg_listings.delete_all
     self.total_price = 0
     self.item_count = 0 
     self.save!
   end
   
end
