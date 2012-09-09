class Mtg::TransactionPayment < ActiveRecord::Base
  self.table_name = 'mtg_transaction_payments'    
  
  belongs_to :transaction,  :class_name => "Mtg::Transaction",  :foreign_key => "transaction_id"
  belongs_to :buyer,        :class_name => "User",              :foreign_key => "user_id" 
  
  # Implement Money gem for price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :price, :buyer, :transaction

  # validations
  validates_presence_of :price, :buyer, :transaction
  validates             :price, :numericality => {:greater_than => 0, :less_than => 5000000, :message => "Must be between $0.01 and $50,000"}   #price must be between $0 and $10,000.00  
  validates             :status,:inclusion =>    {:within => %w(active refunded) }
  validate              :verify_user_has_sufficient_funds  
  
  after_create :charge_user_account
  before_destroy :credit_user_account
  
  def refund
    if buyer.account.balance_credit!(price.dollars)
      self.update_attributes({:status => "refunded"}, :without_protection => true) 
    end
  end
  
  private
  
  def verify_user_has_sufficient_funds
    errors.add(:price, "Insufficient Funds") unless buyer.account.balance >= price
  end
  
  def charge_user_account
    buyer.account.balance_debit!(price.dollars)
  end

  def credit_user_account
    buyer.account.balance_credit!(price.dollars)
  end  

end