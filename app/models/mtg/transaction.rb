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
  
  # check whether seller has rejected this transaction or not
  def seller_rejected?
    return self.seller_rejected_at != nil
  end  
  
  # returns true if buyer has already reviewed this transaction otherwise returns false
  def buyer_reviewed?
    return self.seller_rating.present?
  end
  
  # seller has confirmed this transaction
  def mark_as_seller_confirmed!
    self.update_attribute(:seller_confirmed_at, Time.now)
  end
  
  # seller has rejected this transaction
  def mark_as_seller_rejected!
    self.update_attribute(:seller_rejected_at, Time.now)
  end  

  # reverse seller confirming transaction
  def mark_as_seller_unconfirmed!
    self.update_attribute(:seller_confirmed_at, nil)
  end
  
  # removes listings and ensures they are free to be purchased again
  def remove_listings!
    self.listings.each { |l| l.free! } # free listings in this transaction
    self.listings.clear # delete listings out of this transaction
  end
  
end
