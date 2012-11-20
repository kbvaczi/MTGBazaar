class Mtg::Order < ActiveRecord::Base

  self.table_name = 'mtg_orders'
  
  belongs_to  :cart
  belongs_to  :seller,       :class_name => "User"  
  has_one     :buyer,        :class_name => "User",                     :through => :cart,            :source => :user
  has_one     :transaction,  :class_name => "Mtg::Transaction",                                       :foreign_key => "order_id"
  has_many    :reservations, :class_name => "Mtg::Reservation",         :dependent => :destroy
  has_many    :listings,     :class_name => "Mtg::Cards::Listing",      :through => :reservations,    :source => :listing

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

  attr_accessible :seller_id, :cart_id, :item_price_total, :item_count, :shipping_cost, :total_cost
  
  ##### ------ VALIDATIONS ----- #####

  validates_presence_of         :seller, :cart
  validates :total_cost,        :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000000}  #quantity must be between 0 and $100,000
  validates :item_price_total,  :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000000}  #quantity must be between 0 and $100,000  
  validates :shipping_cost,     :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}      #quantity must be between 0 and $100
  validates :item_count,        :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}  #quantity must be between 0 and 10,000
  validate  :listings_from_one_seller_only
  
  def listings_from_one_seller_only
    self.errors[:base] << "Cannot add listings from multiple sellers to an order" if self.id && listings.pluck(:seller_id).uniq.count > 1
    self.errors[:base] << "Cannot add listings from yourself" if seller == buyer
  end
  
  ##### ------ CALLBACKS ----- #####  


  ##### ------ PUBLIC METHODS ----- #####  
  
  def add_mtg_listing(listing, quantity = 1, update = true)
    if self.listings.include?(listing) # is there already a reservation for this listing in cart?
      res = self.reservations.where(:listing_id => listing.id).first # add to existing reservation
    else
      res = self.reservations.build(:listing_id => listing.id, :quantity => 0) # build a new reservation
    end
    res.increment(:quantity, quantity)
    res.listing.decrement(:quantity_available, quantity)
    if res.valid? && res.listing.valid?
      res.save
      res.listing.save
      self.update_cache if update
      return true # success
    end
    return false # fail
  end

  def remove_mtg_listing(reservation, quantity = 1, update = true)
    if self.reservations.include?(reservation)
      if quantity <= reservation.quantity # remove less quantity than reservation holds, just update quantity in reservation
        reservation.decrement(:quantity, quantity)
        reservation.listing.increment(:quantity_available, quantity)
        if reservation.valid? && reservation.listing.valid?
          reservation.save
          reservation.listing.save
          self.update_cache if update
          self.destroy if self.item_count == 0
          return true # success          
        end  
      end
    end
    return false # fail
  end
  
  def empty
    reservations.each {|r| remove_mtg_listing(r,r.quantity, false)} if item_count > 0
    self.destroy
  end
  
  # creates a transaction and transaction items in preparation for checkout.
  def setup_transaction_for_checkout
    self.transaction.destroy if self.transaction.present?                             # refresh transaction every time we try to check out so we don't get old data
    #TODO: buyer_confirmed_at now obsolete for transactions
    self.build_transaction(:buyer_confirmed_at => Time.now)
    self.reservations.each { |r| self.transaction.build_item_from_reservation(r) }   # create transaction items based on these reservations
    calculated_commission_rate = self.buyer.account.commission_rate || SiteVariable.get("global_commission_rate").to_f
    self.transaction.build_payment( :user_id => self.buyer.id, 
                                    :amount => self.total_cost, 
                                    :shipping_cost => self.shipping_cost, 
                                    :commission_rate => calculated_commission_rate,
                                    :commission => Money.new((calculated_commission_rate * self.item_price_total.cents).ceil)  )  # Calculate commision as commission_rate * item value (without shipping), round up to nearest cent
    self.transaction.save!
  end
    
  def checkout_transaction
    this_transaction = self.transaction                                               # remember this for later
    self.transaction.buyer = self.buyer                                               # setup buyer and seller for transaction
    self.transaction.seller = self.seller                                     
    self.transaction.status = "confirmed"                                             # set transaction to confirmed since money has changed hands
    self.transaction.order_id = nil                                                   # disconnect transaction from order so order can be destroyed
    if self.transaction.save
      self.reservations.each { |r| r.purchased! } rescue true                         # update listing quantity and destroy each reservation for this transaction
      this_transaction.items.each { |i| i.update_attributes({:buyer_id => self.buyer_id, :seller_id => self.seller_id}, :without_protection => true) } rescue true
      self.destroy
    end
  end
  
  ##### ------ PRIVATE METHODS ----- #####          
  protected
  
  def update_cache
    fresh_reservations = self.reservations.includes(:listing)
    if fresh_reservations.count > 0
      self.item_count       = fresh_reservations.to_a.inject(0) {|sum, res| sum + res[:quantity] }
      self.item_price_total = Money.new(fresh_reservations.to_a.inject(0) {|sum, res| sum + res[:quantity] * res.listing[:price]})
      self.shipping_cost    = Mtg::Transactions::ShippingLabel.calculate_shipping_parameters(:card_count => item_count)[:user_charge]        
      self.total_cost       = item_price_total + shipping_cost
    else
      self.item_count       = 0
      self.item_price_total = 0
      self.shipping_cost    = 0
      self.total_cost       = 0
    end
    self.save
  end
  
end
