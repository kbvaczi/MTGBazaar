class Mtg::Transactions::Payment < ActiveRecord::Base
  self.table_name = 'mtg_transaction_payments'    
  
  belongs_to :transaction,          :class_name => "Mtg::Transaction"
  belongs_to :buyer,                :class_name => "User",                                              :foreign_key => "user_id"
  has_one    :payment_notification, :class_name => "Mtg::Transactions::PaymentNotification",            :foreign_key => "payment_id"

  serialize  :paypal_purchase_response

  # Implement Money gem for price column
  composed_of   :amount,
                :class_name => 'Money',
                :mapping => %w(amount cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  

  # Implement Money gem for commission column
  composed_of   :commission,
                :class_name => 'Money',
                :mapping => %w(commission cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }                

  # Implement Money gem for commission column
  composed_of   :shipping_cost,
                :class_name => 'Money',
                :mapping => %w(shipping_cost cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }                
  
  # Setup accessible (or protected) attributes for your model
  #attr_accessible :amount, :buyer, :transaction, :status, :commission, :commission_rate, :paypal_paykey, :paypal_purchase_response

  # validations
  validates_presence_of :paypal_paykey, 
                        :paypal_purchase_response
  validates             :amount,          :numericality => {:greater_than => 0,             :less_than => 5000000, :message => "Must be between $0.01 and $50,000"}   #price must be between $0 and $10,000.00  
  validates             :commission,      :numericality => {:greater_than_or_equal_to => 0, :less_than => 500000,  :message => "Must be between $0.00 and $5,000"}   #price must be between $0 and $10,000.00    
  validates             :commission_rate, :numericality => {:greater_than_or_equal_to => 0, :less_than => 0.15,    :message => "Must be between 0% and 15%"}   #price must be between $0 and $10,000.00      
  validates             :shipping_cost,   :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}      #quantity must be between 0 and $100  
  validates             :status,          :inclusion =>    {:within => %w(unpaid pending completed refunded partially_refunded) }
  
  # Callbacks
  # before_validation     :calculate_costs
  # before_validation     :setup_purchase

  # Public Methods

  def calculate_costs
    self.amount          = self.transaction.shipping_cost + self.transaction.value
    self.shipping_cost   = self.transaction.shipping_cost
    self.commission_rate = self.buyer.account.commission_rate || SiteVariable.get("global_commission_rate").to_f       # Calculate commission rate, if neither exist commission is set to 0
    self.commission      = Money.new((commission_rate * self.transaction.value.cents).ceil)                # Calculate commision as commission_rate * item value (without shipping), round up to nearest cent
  end
  
  def compute_key
    #TODO: encrypt secret and change per order basis
    return PAYPAL_CONFIG[:secret]
  end  

  
end