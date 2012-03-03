class Account < ActiveRecord::Base

  # --------------------------------------- #
  # ------------ Database Relationships --- #
  # --------------------------------------- #

  belongs_to :user
  has_many :balance_transfers, :class_name => 'AccountBalanceTransfer', :dependent => :destroy    

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
  
end