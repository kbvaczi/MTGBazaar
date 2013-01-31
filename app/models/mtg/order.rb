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
  
  serialize     :shipping_options
  
  ##### ------ VALIDATIONS ----- #####

  validates_presence_of         :seller, :cart
  validates :total_cost,        :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000000}  #quantity must be between 0 and $100,000
  validates :item_price_total,  :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000000}  #quantity must be between 0 and $100,000  
  validates :shipping_cost,     :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}      #quantity must be between 0 and $100
  validates :item_count,        :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}  #quantity must be between 0 and 10,000
  validate  :listings_from_one_seller_only
  validate  :validate_shipping_options
  
  def listings_from_one_seller_only
    #self.errors[:base] << "Cannot add listings from multiple sellers to an order" if self.id && listings.pluck(:seller_id).uniq.count > 1
    self.errors[:base] << "Cannot add listings from yourself" if seller == buyer
  end
  
  def validate_shipping_options
    # only users authorized to have pickup 
    self.shipping_options[:shipping_type]    = 'usps' unless self.seller.ship_option_pickup_available?
    # signature confirmation is required for all orders over $250
    if self.item_price_total >= 250.to_money and self.shipping_options[:shipping_charges][:signature_confirmation].nil?
      self.shipping_options[:shipping_charges][:signature_confirmation] = Mtg::Transactions::ShippingLabel.calculate_shipping_parameters(:signature => true)[:shipping_options_charges][:signature_confirmation] 
    end
  end
  
  ##### ------ CALLBACKS ----- #####  
  
  after_initialize :set_default_shipping_options

  ##### ------ HELPERS ------------ #####

  ##### ------ PUBLIC METHODS ----- #####  
  
  def add_mtg_listing(listing, quantity = 1, update = true)
    if self.listings.include?(listing) # is there already a reservation for this listing in cart?
      res = self.reservations.where(:listing_id => listing.id).first # add to existing reservation
    else
      res = self.reservations.build(:listing_id => listing.id, :quantity => 0, :cards_quantity => 0) # build a new reservation
    end
    res.increment(:quantity, quantity)
    res.increment(:cards_quantity, (quantity * listing.number_cards_per_item))    
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
        reservation.decrement(:cards_quantity, (quantity * reservation.listing.number_cards_per_item))            
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
    ActiveRecord::Base.transaction do     
      self.create_transaction!(  :buyer              => self.buyer,
                                 :seller             => self.seller,
                                 :cards_quantity     => self.cards_quantity,
                                 :shipping_options    => self.shipping_options,                                 
                                 :shipping_cost      => self.shipping_cost,
                                 :value              => self.item_price_total )
      self.reservations.includes(:listing).each { |r| self.transaction.create_item_from_reservation!(r) }   # create transaction items based on these reservations
      calculated_commission_rate = self.buyer.account.commission_rate || SiteVariable.get("global_commission_rate").to_f
      self.transaction.create_payment!( :user_id          => self.buyer.id, 
                                        :amount           => self.total_cost, 
                                        :shipping_cost    => self.shipping_cost, 
                                        :commission_rate  => calculated_commission_rate,
                                        :commission       => Money.new((calculated_commission_rate * self.item_price_total.cents).ceil)  )  # Calculate commision as commission_rate * item value (without shipping), round up to nearest cent                                
    end
  end
    
  def checkout_transaction
    this_transaction = self.transaction                                                 # remember this for later because we will disconnect transaction from order
    self.transaction.assign_attributes(:buyer_confirmed_at  => Time.zone.now,
                                       :status              => "confirmed",
                                       :order_id            => nil )                    # disconnect this transaction from order
    ActiveRecord::Base.transaction do                                 
      self.transaction.save!
      self.reservations.each { |r| r.purchased! } rescue true    # update listing quantity and destroy each reservation for this transaction
      self.destroy
    end
    #update seller sales count
    self.seller.statistics.increment(:number_sales).save
    #update card sales statistics offline using worker
    Mtg::Cards::Statistics.delay.bulk_update_sales_information(this_transaction.items.pluck(:card_id))
  end
  

  def update_cache
     fresh_reservations = self.reservations.includes(:listing)
     if fresh_reservations.count > 0
       self.item_count       = fresh_reservations.pluck(:quantity).inject(0) {|sum, value| sum + value }
       self.cards_quantity   = fresh_reservations.pluck(:cards_quantity).inject(0) {|sum, value| sum + value }
       self.item_price_total = Money.new(fresh_reservations.to_a.inject(0) {|sum, res| sum + res[:quantity] * res.listing[:price]})
       
       shipping_parameters   = Mtg::Transactions::ShippingLabel.calculate_shipping_parameters(:card_count    => self.cards_quantity,
                                                                                              :insurance     => self.shipping_options[:shipping_charges][:insurance].present?,
                                                                                              :item_value    => self.item_price_total,
                                                                                              :signature     => self.shipping_options[:shipping_charges][:signature_confirmation].present?,
                                                                                              :shipping_type => self.shipping_options[:shipping_type])
       self.shipping_options[:shipping_charges].merge!(shipping_parameters[:shipping_options_charges])
       self.shipping_cost    = self.shipping_options[:shipping_type] == 'usps' ? shipping_parameters[:total_shipping_charge] : 0.to_money
       self.total_cost       = item_price_total + shipping_cost
     else
       self.item_count       = 0
       self.cards_quantity   = 0      
       self.item_price_total = 0
       self.shipping_cost    = 0
       self.total_cost       = 0
     end
     self.save
   end
  
   ##### ------ PRIVATE METHODS ----- #####          
   protected
  
  def set_default_shipping_options
    self.shipping_options ||= { :shipping_type    => 'usps', 
                                :shipping_charges => { } }
  end
 
end
