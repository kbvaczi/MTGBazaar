class Users::Deposit < ActiveRecord::Base
  belongs_to :account

  validates             :balance,           :numericality => { :only_integer => true, :greater_than_or_equal_to => 1000 }

  # Setup accessible (or protected) attributes for your model
  attr_accessible :balance, :current_password
  
  # not-in-model field for current password confirmation
  attr_accessor :current_password

  
end
