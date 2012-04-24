class Mtg::Reservation < ActiveRecord::Base
  self.table_name = 'mtg_reservations'    

  belongs_to :cart
  belongs_to :listing,  :class_name => "Mtg::Listing",  :foreign_key => "listing_id"
  has_one    :seller,       :class_name => "User",          :through => :listing
  has_one    :card,         :class_name => "Mtg::Card",     :through => :listing
  
  
  def purchased!
    self.listing.decrement(:quantity, self.quantity).save
    self.destroy
  end
end