class Mtg::Transaction < ActiveRecord::Base
# ---------------- MODEL SETUP ----------------

  self.table_name = 'mtg_transactions'
  
  belongs_to :seller,         :class_name => "User"
  belongs_to :buyer,          :class_name => "User"
  belongs_to :order,          :class_name => "Mtg::Order"
  has_many   :communications, :class_name => "Communication",                       :foreign_key => "mtg_transaction_id", :dependent => :destroy
  has_one    :payment,        :class_name => "Mtg::Transactions::Payment",          :foreign_key => "transaction_id",     :dependent => :destroy
  has_one    :shipping_label, :class_name => "Mtg::Transactions::ShippingLabel",    :foreign_key => "transaction_id",     :dependent => :destroy
  has_one    :feedback,       :class_name => "Mtg::Transactions::Feedback",         :foreign_key => "transaction_id",     :dependent => :destroy
  has_many   :items,          :class_name => "Mtg::Transactions::Item" ,            :foreign_key => "transaction_id",     :dependent => :destroy


  # Implement Money gem for price column
  composed_of   :value,
                :class_name => 'Money',
                :mapping => %w(value cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }

  # Implement Money gem for price column
  composed_of   :shipping_cost,
                :class_name => 'Money',
                :mapping => %w(shipping_cost cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }                  

  # override default route to add username in route.
  def to_param
    "#{id}-#{transaction_number}".parameterize 
  end

# ---------------- CALLBACKS ------------------

  before_validation :update_transaction_costs
  before_create     :generate_transaction_number                  
  
# ---------------- VALIDATIONS ----------------      

  validates               :value, :numericality => {:greater_than => 0, :less_than => 5000000, :message => "Must be between $0.01 and $50,000"}   #price must be between $0 and $10,000.00    
  validates               :shipping_cost, :numericality => {:greater_than => 150, :less_than => 3000, :message => "Must be between $1.50 and $30"}
  validates_associated    :items
  validate                :self_buying_not_allowed
  
  def self_buying_not_allowed
    self.errors[:base] << "You cannot buy from yourself..." if seller_id == buyer_id && buyer_id != nil
  end

# ---------------- SCOPES ---------------------------

  def self.active
    where("mtg_transactions.status <> \'completed\'")
  end
  
  def self.recent
    where("mtg_transactions.created_at > \'#{1.month.ago}\'")
  end
  
  def self.paid
    where("mtg_transactions.status <> ?", "unpaid")
  end

  def self.ready_to_ship
    where(:seller_shipped_at => nil, :status => "confirmed")
  end
  
  def self.shipped
    where("mtg_transactions.seller_shipped_at <> \'nil\'")
  end
  
  def self.with_feedback
    includes(:feedback).where("mtg_transactions_feedback.id > 0")
  end
  
  def self.completed
    where(:status => "completed")
  end

# ---------------- PUBLIC MEMBER METHODS -------------
  
  def total_value
    self.shipping_cost + self.value
  end
    
  def item_count
    #items.select(:quantity_available).to_a.sum(&:quantity_available)
    self.items.pluck(:quantity_available).inject(0) { |sum, value| sum + value }
  end
  
  def display_feedback
    case self.buyer_feedback
      when "1"
        "Positive"
      when "-1"
        "Negative"
      when "0"
        "Neutral"
    end
  end
  
  def valid_for_communication?
    return self.created_at >= 30.days.ago && (not self.feedback.present?)
  end
  
  # check whether seller has confirmed this transaction or not
  def seller_confirmed?
    return self.seller_confirmed_at != nil
  end
  
  # check whether seller has rejected this transaction or not
  def seller_rejected?
    return self.seller_rejected_at != nil
  end  
  
  # returns true if buyer has already reviewed this transaction otherwise returns false
  def buyer_reviewed?
    return self.seller_rating.present?
  end
  
  # seller has confirmed this transaction
  def confirm_sale
    self.update_attributes(:seller_confirmed_at => Time.now, :status => "confirmed")
  end

  # buyer confirms seller's modifications to sale
  def mark_as_buyer_confirmed_with_modifications!
    self.update_attributes(:buyer_confirmed_at => Time.now, :status => "confirmed") # record buyer's confirmation time
    self.items.each { |item| item.update_attributes(:quantity_requested => item.quantity_available) if item.quantity_available != item.quantity_requested } # update item quantities in the transaction
  end  
  
  # seller has rejected this transaction
  def reject_sale(rejection_reason, response_message = nil)
    if self.update_attributes(:seller_rejected_at => Time.now, :status => "rejected", :rejection_reason => rejection_reason, :response_message => response_message)
      self.payment.refund
      self.reject_items!
    end
  end  
  
  # seller has shipped this transaction
  def ship_sale(options = {:shipped_at => Time.now})
    self.update_attributes(:seller_shipped_at => options[:shipped_at], :status => "shipped")
  end  
  
  # seller has delivered this transaction
  def deliver_sale(buyer_feedback, buyer_feedback_text)
    if update_attributes(:buyer_feedback => buyer_feedback, :buyer_feedback_text => buyer_feedback_text, :seller_delivered_at => Time.now, :status => "delivered")
      self.credit = Mtg::TransactionCredit.create({:seller => self.seller, :transaction => self, :price => self.total_value, :commission => 0, :commission_rate => 0}, :without_protection => true)
      buyer.statistics.update_buyer_statistics!
      seller.statistics.update_seller_statistics!
      update_card_statistics!
    end
  end  
  
  # buyer has canceled this sale
  def cancel_sale(reason)
    if self.update_attributes(:status => "cancelled", :cancellation_reason => reason)
      self.payment.refund
      self.reject_items!
    end
  end
  
  # creates a dummy copy of listings to be saved with rejected transaction (for tracking purposes) then frees all originals so they can be purchased again
  def reject_items!
    self.items.each do |i|
      i.update_attribute(:rejected_at, Time.now)
      self.create_listing_from_item(i)
    end
  end
  
  def build_item_from_reservation(reservation)
    self.items.build(                {:quantity_requested => reservation.quantity,
                                     :quantity_available => reservation.quantity,
                                     :price => reservation.listing.price,
                                     :condition => reservation.listing.condition,
                                     :language => reservation.listing.language,
                                     :description => reservation.listing.description,
                                     :altart => reservation.listing.altart,
                                     :misprint => reservation.listing.misprint,
                                     :playset => reservation.listing.playset,                                     
                                     :number_cards_per_item => reservation.listing.number_cards_per_item,                                                                          
                                     :foil => reservation.listing.foil,
                                     :signed => reservation.listing.signed,
                                     :card_id => reservation.listing.card_id,
                                     :buyer => self.buyer,
                                     :seller => self.seller,
                                     :transaction => self},
                                     :without_protection => true)
  end
  
  def create_listing_from_item(item)
    listing = Mtg::Cards::Listing.new(:quantity => item.quantity_available,
                                     :price => item.price,
                                     :condition => item.condition,
                                     :language => item.language,
                                     :description => item.description,
                                     :altart => item.altart,
                                     :misprint => item.misprint,
                                     :foil => item.foil,
                                     :signed => item.signed,
                                     :playset => item.playset,                                     
                                     :number_cards_per_item => item.number_cards_per_item )
    listing.card_id = item.card_id
    listing.seller_id = self.seller_id
    duplicate = Mtg::Cards::Listing.duplicate_listings_of(listing).first
    if duplicate.present? # there is already a duplicate listing, just update quantity of cards
      duplicate.update_attributes(  :quantity => duplicate.quantity + item.quantity_available, 
                                    :quantity_available => duplicate.quantity_available + item.quantity_available )
    else # there is no duplicate listing, create a new one from item
      listing.save
    end
  end
  
  def update_card_statistics!
    self.items.includes({:card => :statistics}).each {|i| i.card.statistics.update!}
  end

# ---------------- PRIVATE MEMBER METHODS -------------  
  private
  
  def update_transaction_costs
    self.value         = self.items.to_a.inject(0) {|sum, item| sum + item.quantity_requested * item.price.dollars}.to_money
    self.shipping_cost = Mtg::Transactions::ShippingLabel.calculate_shipping_parameters(:card_count => self.cards_quantity)[:user_charge]
  end
  
  def generate_transaction_number
    begin
      token = SecureRandom.urlsafe_base64(12).gsub(/[-=_]/,"0").upcase
    end while Mtg::Transaction.where(:transaction_number => token).exists?
    self.transaction_number = token
  end
  
end
