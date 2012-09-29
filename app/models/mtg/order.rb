class Mtg::Order < ActiveRecord::Base

  self.table_name = 'mtg_orders'
  
  belongs_to  :cart
  belongs_to  :seller,       :class_name => "User"  
  has_many    :reservations, :class_name => "Mtg::Reservation", :dependent => :destroy
  has_one     :buyer,        :class_name => "User",             :through => :cart,            :source => :user
  has_many    :listings,     :class_name => "Mtg::Listing" ,    :through => :reservations,    :source => :listing

  # Implement Money gem for item_price_total column
  composed_of   :item_price_total,
                :class_name => 'Money',
                :mapping => %w(item_price_total cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
                
  # Implement Money gem for item_price_total column
  composed_of   :shipping_cost,
                :class_name => 'Money',
                :mapping => %w(shipping_cost cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }                

  # Implement Money gem for item_price_total column
  composed_of   :total_cost,
                :class_name => 'Money',
                :mapping => %w(total_cost cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }                

  attr_accessible :seller_id, :item_price_total, :item_count, :shipping_cost, :total_cost
  
  ##### ------ VALIDATIONS ----- #####

  validates_presence_of   :seller, :cart
  validates :total_cost, :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000000}  #quantity must be between 0 and $100,000
  validates :item_count,  :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}  #quantity must be between 0 and 10,000
  validate  :listings_from_one_seller_only
  
  def listings_from_one_seller_only
    Rails.logger.info("LISTINGS: #{listings.pluck(:seller_id)}")  
    self.errors[:base] << "Cannot add listings from multiple sellers to an order" if self.id && listings.pluck(:seller_id).uniq.count > 1
  end
  
  ##### ------ CALLBACKS ----- #####  
  
  after_save :delete_if_empty
  
  def delete_if_empty
    self.destroy if total_cost == 0 && item_count == 0
  end
  
  ##### ------ PUBLIC METHODS ----- #####  
  
  def add_mtg_listing(listing, quantity = 1, update = true)
    if self.listings.include?(listing) # is there already a reservation for this listing in cart?
      res = self.reservations.where(:listing_id => listing.id).first # add to existing reservation
      Rails.logger.info("USING EXISTING RESERVATION")      
    else
      res = self.reservations.build(:listing_id => listing.id, :quantity => 0) # build a new reservation
      Rails.logger.info("CREATING NEW RESERVATION")
    end
    res.increment(:quantity, quantity)
    res.listing.decrement(:quantity_available, quantity)
    if res.valid? && res.listing.valid? && self.update_cache
      self.save
      res.save
      res.listing.save
      return true # success
    else
      Rails.logger.info("res_errors: #{res.errors.full_messages}")
      Rails.logger.info("listing_errors: #{res.listing.errors.full_messages}")      
      Rails.logger.info("order_errors: #{self.errors.full_messages}")
      return false # fail
    end
  end

  def remove_mtg_listing(reservation, quantity = 1, update = true)
    if self.reservations.include?(reservation)
      if quantity <= reservation.quantity # remove less quantity than reservation holds, just update quantity in reservation
        reservation.decrement(:quantity, quantity)
        reservation.listing.increment(:quantity_available, quantity)
        if reservation.valid? && reservation.listing.valid? && self.update_cache
          reservation.save
          reservation.listing.save
          self.save
          return true # success          
        end  
      end
    end
    return false # fail
  end
  
  def empty
    reservations.each {|r| remove_mtg_listing(r,r.quantity, false)} if item_count > 0
    self.update_cache
  end
  
  ##### ------ PRIVATE METHODS ----- #####          
  protected
  
  def update_cache
    res = reservations.includes(:listing)
    Rails.logger.info("RESERVATIONS: #{res.to_a}")
    self.item_count = res.to_a.count.to_i
    self.item_price_total = Money.new(res.to_a.inject(0) {|sum, res| sum + res[:quantity] * res.listing[:price]})
    Rails.logger.info("item_count: #{item_count}")
    Rails.logger.info("item_total_price: #{item_price_total}")    
    self.shipping_cost = Mtg::Transactions::ShippingLabel.calculate_shipping_parameters(:item_count => item_count)[:user_charge]
    Rails.logger.info("shipping cost: #{shipping_cost}")        
    self.total_cost = (item_price_total + shipping_cost)
    Rails.logger.info("total: #{total_cost}")    
    Rails.logger.info("update_cache_valid?: #{self.valid?}")          
    return self.valid?
    #
    #self.item_count = reservations.sum("mtg_reservations.quantity")
    #self.total_price = reservations.sum("mtg_listings.price * mtg_reservations.quantity").to_f / 100
    #self.save
  end
  
end
