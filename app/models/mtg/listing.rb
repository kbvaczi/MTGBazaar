class Mtg::Listing < ActiveRecord::Base
  set_table_name :mtg_listings
  
  belongs_to :card, :class_name => "Mtg::Card"
  belongs_to :seller, :class_name => "User"  
  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :set, :quantity, :price, :condition, :language, :description, :foreign, :defect, :foil

  # not-in-model field for current password confirmation
  attr_accessor :name, :set, :quantity

end
