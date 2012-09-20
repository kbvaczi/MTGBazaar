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
  attr_accessible :price, :buyer, :transaction, :status

  # validations
  validates             :price,     :numericality => {:greater_than => 0, :less_than => 5000000, :message => "Must be between $0.01 and $50,000"}   #price must be between $0 and $10,000.00  
  validates             :status,    :inclusion =>    {:within => %w(active refunded) }
  validate              :verify_account
  
  before_create         :charge_user_account

  def refund
    if buyer.account.balance_credit!(price.dollars)
      self.update_attributes({:status => "refunded"}, :without_protection => true) 
    end
  end
  
  private
  
  def verify_account
    errors.add(:buyer, "Insufficient Funds") unless buyer.account.balance >= price
    errors.add(:buyer, "Invalid Account") unless buyer.account.valid?    
  end
  
  def charge_user_account
    Rails.logger.info("trying to charge user account #{price.dollars}, account is currently at #{buyer.account.balance.dollars}")    
    if buyer.account.balance_debit!(price.dollars)
      Rails.logger.info("Successfully charged user account #{price.dollars}, account is now at #{buyer.account.balance.dollars}")  
    else
      errors.add(:price, "Account couldn't be charged, account is currently at #{buyer.account.balance.dollars}")
      Rails.logger.info("Account was not charged, #{buyer.account.errors.full_messages}")  
    end
  end

  def credit_user_account
    errors.add(:price, "Account couldn't be charged") unless buyer.account.balance_credit!(price.dollars)
  end
  


end