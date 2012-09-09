class Mtg::TransactionCredit < ActiveRecord::Base
  self.table_name = 'mtg_transaction_credits'    
  
  belongs_to :transaction,  :class_name => "Mtg::Transaction",  :foreign_key => "transaction_id"
  belongs_to :seller,       :class_name => "User",              :foreign_key => "user_id" 
  
  # Implement Money gem for price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  

  # Implement Money gem for commission column
  composed_of   :commission,
                :class_name => 'Money',
                :mapping => %w(commission cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },    
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }                
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :price, :commission, :seller, :transaction

  # validations
  validates_presence_of :price, :commission, :seller, :transaction
  validates             :price,           :numericality => {:greater_than => 0,             :less_than => 5000000, :message => "Must be between $0.01 and $50,000"}   
  validates             :commission,      :numericality => {:greater_than_or_equal_to => 0, :less_than => 500000,  :message => "Must be between $0 and $5000"}   
  validates             :commission_rate, :numericality => {:greater_than_or_equal_to => 0, :less_than => 0.1,     :message => "Invalid Commission Rate"},
                                          :allow_nil => true
  validates             :status,          :inclusion =>    {:within => %w(active refunded) }

  after_create :credit_user_account
  before_destroy :charge_user_account  
  
  def charge_user_account
    User.find(user_id).account.balance_debit!(price.dollars)
  end

  def credit_user_account
    User.find(user_id).account.balance_credit!(price.dollars)
  end  

end