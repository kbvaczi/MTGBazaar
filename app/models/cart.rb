class Cart < ActiveRecord::Base

  belongs_to  :user
  has_many    :orders,        :class_name => "Mtg::Order",        :dependent => :destroy
  has_many    :reservations,  :class_name => "Mtg::Reservation",  :through => :orders
  has_many    :listings,      :class_name => "Mtg::Listing" ,     :through => :reservations
  
  # Implement Money gem for total_price column
  composed_of   :total_price,
                :class_name => 'Money',
                :mapping => %w(total_price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  

  attr_accessible :user_id, :total_price, :item_count
  
  validates_presence_of   :user
  validates :total_price, :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000000}  #quantity must be between 0 and $100,000
  validates :item_count,  :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}  #quantity must be between 0 and 10,000
                    
  def add_mtg_listing(listing, quantity = 1)
    order = self.orders.where(:seller_id => listing.seller.id).first || self.orders.build(:seller_id => listing.seller.id) # add listing to existing order, or create a new order if one doesn't exist for this seller
    if order.add_mtg_listing(listing, quantity) #add listing to order
      self.update_cache
      return true
    end
    return false
    Rails.logger.info("cart add failed")
  end

  def remove_mtg_listing(reservation, quantity = 1)
    if self.reservations.include?(reservation) # does this cart contain this reservation?
      order = self.orders.where(:seller_id => reservation.listing.seller_id).first
      if order.remove_mtg_listing(reservation, quantity)
        self.update_cache
        return true
      end
    end
    return false
  end
  
  def update_cache
    res = reservations.joins(:listing)
    self.item_count = res.sum("mtg_reservations.quantity")
    self.total_price = res.sum("mtg_listings.price * mtg_reservations.quantity").to_f / 100
    self.save
  end

  def empty
    self.orders.each {|o| o.empty} if self.item_count > 0
    self.update_cache
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
