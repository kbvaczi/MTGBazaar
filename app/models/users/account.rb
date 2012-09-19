class Account < ActiveRecord::Base

  # --------------------------------------- #
  # ------------ Database Relationships --- #
  # --------------------------------------- #

  belongs_to :user
  has_many   :balance_transfers, :class_name => 'AccountBalanceTransfer', :dependent => :destroy    
  serialize  :address_verification

  # Implement Money gem for balance column
  composed_of   :balance,
                :class_name => 'Money',
                :mapping => %w(balance cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }

  # --------------------------------------- #
  # ------------ Validations -------------- #
  # --------------------------------------- #

  #before_validation     :format_address_verification
  
  validates_presence_of :first_name, 
                        :last_name, 
                        :country, 
                        :state, 
                        :city, 
                        :address1,
                        :address_verification,
                        :zipcode
                        

  validates             :state, :format => { :with => /\A[A-Z]{2}\z/, :message => "Please enter a valid State Abbreviation" }

  # matches 5-digit US zipcodes only
  validates             :zipcode, :format => { :with => /\A\d{5}\z/, :message => "Please enter a valid 5 digit zipcode" }
  
  # only letters (or spaces) allowed in the following
  validates             :first_name,
                        :last_name,
                        :country, :format => { :with => /\A[a-zA-Z .]+\z/, :message => "Only letters allowed" }
  
  validates             :first_name, 
                        :last_name, 
                        :country, 
                        :state, 
                        :city, 
                        :address1, 
                        :zipcode,
                        :length => {
                           :minimum   => 2,
                           :maximum   => 30,
                         }
                         
  validates             :balance, :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000000, :message => "Must be between $0.00 and $100,000"}   #price must be between $0 and $10,000.00                           

  # Attributes accessible to multiple assign.  Others must be individually assigned.
  attr_accessible :first_name, :last_name, :country, :state, :city, :address1, :address2, :zipcode, :security_question, :security_answer, :paypal_username, :address_verification
  
  # returns full name of user
  def full_name
    first_name + " " + last_name
  end
  
  # credit this account's balance with amount in dollars
  def balance_credit!(amount=0)
    self.balance += amount.to_money
    self.save
  end

  # debit this account's balance with amount in dollars
  def balance_debit!(amount=0)
    self.balance -= amount.to_money
    self.save
  end  
  
end
