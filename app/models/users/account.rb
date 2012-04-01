class Account < ActiveRecord::Base

  # --------------------------------------- #
  # ------------ Database Relationships --- #
  # --------------------------------------- #

  belongs_to :user
  has_many :balance_transfers, :class_name => 'AccountBalanceTransfer', :dependent => :destroy    

  # Implement Money gem for balance column
  composed_of   :balance,
                :class_name => 'Money',
                :mapping => %w(balance cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }

  # --------------------------------------- #
  # ------------ Validations -------------- #
  # --------------------------------------- #

  validates_presence_of :first_name, 
                        :last_name, 
                        :country, 
                        :state, 
                        :city, 
                        :address1, 
                        :zipcode

  # only numbers allowed in the following
  validates             :zipcode,     :numericality => { :only_integer => true }
  
  # only letters (or spaces) allowed in the following
  validates             :first_name,
                        :last_name,
                        :state,
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

  # Attributes accessible to multiple assign.  Others must be individually assigned.
  attr_accessible :first_name, :last_name, :country, :state, :city, :address1, :address2, :zipcode, :security_question, :security_answer
  
  # returns full name of user
  def full_name
    first_name + " " + last_name
  end
  
  # credit this account's balance with amount in dollars
  def balance_credit!(amount=0)
    self.balance += amount.to_money
    self.save!
#    if amount.class == Fixnum #amount is a number, do straight math
#      self.update_attribute(:balance, self.balance.dollars + amount)    
#    elsif amount.class == Money # amount is a money class... need to get dollar value before doing math
#      self.update_attribute(:balance, self.balance.dollars + amount.dollars)    
#    end
  end

  # debit this account's balance with amount in dollars
  def balance_debit!(amount=0)
    self.balance -= amount.to_money
    self.save!
#    if amount.class == Fixnum #amount is a number, do straight math
#      self.update_attribute(:balance, self.balance.dollars - amount)    
#    elsif amount.class == Money # amount is a money class... need to get dollar value before doing math
#      self.update_attribute(:balance, self.balance.dollars - amount.dollars)    
#    end
  end  
  
end
