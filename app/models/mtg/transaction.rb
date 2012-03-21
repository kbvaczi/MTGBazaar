class Mtg::Transaction < ActiveRecord::Base
  self.table_name = 'mtg_transactions'
  
  belongs_to :seller,   :class_name => "User"
  belongs_to :buyer,    :class_name => "User"
  has_many :listings,   :class_name => "Mtg::Listing", :foreign_key => "transaction_id"
  
  def total_value
     Mtg::Listing.by_id(listing_ids).to_a.sum(&:price)
  end
  
  # check whether seller has confirmed this transaction or not
  def seller_confirmed?
    return self.seller_confirmed_at != nil
  end
  
  # seller has confirmed this transaction
  def mark_as_seller_confirmed!
    self.update_attribute(:seller_confirmed_at, Time.now)
  end

  # reverse seller confirming transaction
  def mark_as_seller_unconfirmed!
    self.update_attribute(:seller_confirmed_at, nil)
  end
  
end
