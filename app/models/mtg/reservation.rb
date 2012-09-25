class Mtg::Reservation < ActiveRecord::Base
  self.table_name = 'mtg_reservations'    

  belongs_to :cart
  has_one    :buyer,        :class_name => "User",          :through => :cart,              :source => :user
  belongs_to :listing,      :class_name => "Mtg::Listing",  :foreign_key => "listing_id"
  has_one    :seller,       :class_name => "User",          :through => :listing
  has_one    :card,         :class_name => "Mtg::Card",     :through => :listing
  
  validate              :seller_cannot_be_buyer, :on => :create
  validates :quantity,  :numericality => {:greater_than => 0, :less_than => 10000}  #quantity must be between 0 and 10000
  validates_associated  :listing, :cart
  
  def seller_cannot_be_buyer
    self.errors[:base] << "You cannot buy from yourself..." if buyer == seller
  end
  
  def purchased!
    self.listing.decrement(:quantity, self.quantity).save
    self.destroy
  end
  
end