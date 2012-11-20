class Account < ActiveRecord::Base

  # --------------------------------------- #
  # ------------ Database Relationships --- #
  # --------------------------------------- #

  belongs_to :user
  serialize  :address_verification

  # Attributes accessible to multiple assign.  Others must be individually assigned.
  attr_accessible :first_name, :last_name, :country, :state, :city, :address1, :address2, :zipcode, :security_question, :security_answer, :paypal_username, :address_verification
  attr_encrypted  :security_answer, :key => 'shamiggidybobbyokomoto', :encode => true  
  attr_accessor   :paypal_verified

  # ------------ Callbacks -------------- #
  
  after_save    :set_seller_status_to_false_if_paypal_removed
  after_create  :set_seller_status_to_true_if_paypal_entered
  
  def set_seller_status_to_false_if_paypal_removed
    if (not self.paypal_username.present?) and self.user.active
      self.user.update_attribute(:active, false)
    end
  end
  
  def set_seller_status_to_true_if_paypal_entered
    if self.paypal_username.present? and !self.user.active
      self.user.update_attribute(:active, true)
    end
  end

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
                        
  if Rails.env.production?                        
    validates_uniqueness_of :paypal_username, :case_sensitive => false
  end

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
                         
  validate              :verified_paypal_account
  
  def verified_paypal_account
    errors.add(:paypal_username, "Only verified PayPal accounts are accepted...") if self.paypal_verified == false && self.paypal_username.present?
  end                         

  # returns full name of user
  def full_name
    first_name + " " + last_name
  end
  
end
