class Account < ActiveRecord::Base

  # --------------------------------------- #
  # ------------ Database Relationships --- #
  # --------------------------------------- #

  belongs_to :user
  serialize  :address_verification

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
                        :zipcode,
                        :security_question,
                        :security_answer
                        

  validates             :state, :format => { :with => /\A[A-Z]{2}\z/, :message => "Please enter a valid State Abbreviation" }

  # matches 5-digit US zipcodes only
  validates             :zipcode, :format => { :with => /\A\d{5}\z/, :message => "Please enter a valid 5 digit zipcode" }
  
  # only letters (or spaces) allowed in the following
  validates             :first_name,
                        :last_name,
                        :country, :format => { :with => /\A[a-zA-Z .]+\z/, :message => "Only letters allowed" }
  
  validates             :first_name, 
                        :last_name, 
                        :length => {
                           :minimum   => 2,
                           :maximum   => 30,
                         }
                         
  # Attributes accessible to multiple assign.  Others must be individually assigned.
  attr_accessible :first_name, :last_name, :country, :state, :city, :address1, :address2, :zipcode, :security_question, :security_answer, :paypal_username, :address_verification
  
  # returns full name of user
  def full_name
    first_name + " " + last_name
  end
  
end
