class Account < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :first_name

  attr_accessible :first_name, :last_name, :country, :state, :city, :address1, :address2, :zipcode, :birthdate
  
end
