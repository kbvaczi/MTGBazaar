class Mtg::Reservation < ActiveRecord::Base
  self.table_name = 'mtg_reservations'    

  belongs_to :listing,      :class_name => "Mtg::Listing",                          :foreign_key => "listing_id"
  belongs_to :order,        :class_name => "Mtg::Order",                            :foreign_key => "order_id"
  has_one    :seller,       :class_name => "User",          :through => :listing
  has_one    :card,         :class_name => "Mtg::Card",     :through => :listing
  has_one    :cart,         :class_name => "Cart",          :through => :order  
  
  attr_accessible :listing_id, :order_id, :quantity
  
  ##### ------ VALIDATIONS ----- #####
  
  validate              :seller_cannot_be_buyer, :on => :create
  validates :quantity,  :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}  #quantity must be between 0 and 10000
  
  def seller_cannot_be_buyer
    self.errors[:base] << "You cannot buy from yourself..." if buyer == seller
  end

  ##### ------ CALLBACKS ----- #####  

  after_save     :delete_if_empty
  
  def delete_if_empty
    self.destroy if quantity == 0
  end

  ##### ------ PUBLIC METHODS ----- #####  
  
  def buyer
    self.order.buyer
  end
  
  def purchased!
    listing.decrement(:quantity, self.quantity).save
    self.quantity = 0
    self.destroy
  end

  ##### ------ PRIVATE METHODS ----- #####          
  private
  
end