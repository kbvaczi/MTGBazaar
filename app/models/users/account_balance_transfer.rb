class AccountBalanceTransfer < ActiveRecord::Base
  belongs_to  :account
  has_one     :payment_notification

  validates_numericality_of :balance
  validate                  :balance_greater_than_zero
  validates                 :current_password,    :numericality => { :equal_to => 1, :message => "Your password does not match" }

  def balance_greater_than_zero
    errors.add(:balance, "Must be greater than zero") if balance <= 0
  end
 
  # Setup accessible (or protected) attributes for your model
  attr_accessible :balance, :current_password
  
  # not-in-model field for current password confirmation
  attr_accessor :current_password
  
  # Implement Money gem for balance column
  composed_of   :balance,
                :class_name => 'Money',
                :mapping => %w(balance cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }
  
  def self.withdraws
    AccountBalanceTransfer.where(:transfer_type => "withdraw")
  end
  
  def self.deposits
    AccountBalanceTransfer.where(:transfer_type => "deposit")
  end
  
end
