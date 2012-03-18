class AccountBalanceTransfer < ActiveRecord::Base
  belongs_to :account

  #validates             :balance,             :numericality => { :only_integer => true, :greater_than_or_equal_to => 1000, :message => "Minimum is $10.00" }
  validates             :current_password,    :numericality => { :equal_to => 1, :message => "Your password does not match" }

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
  
end
