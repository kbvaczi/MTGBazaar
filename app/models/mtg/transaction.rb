class Mtg::Transaction < ActiveRecord::Base
  self.table_name = 'mtg_transactions'
  
  belongs_to :seller,   :class_name => "User"
  belongs_to :buyer,    :class_name => "User"
  has_many :listings,   :class_name => "Mtg::Listing", :foreign_key => "transaction_id"
  
  # returns the total value of a transaction
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
    self.update_attributes(:seller_confirmed_at => Time.now, :status => "confirmed")
  end
  
  # seller has rejected this transaction
  def mark_as_seller_rejected!(rejection_reason, rejection_message = nil)
    self.update_attributes(:seller_rejected_at => Time.now, :status => "rejected", :rejection_reason => rejection_reason, :rejection_message => rejection_message)
  end  

  # reverse seller confirming transaction
  def mark_as_seller_unconfirmed!
    self.update_attributes(:seller_confirmed_at => nil, :status => "pending")
  end
  
  # seller has shipped this transaction
  def mark_as_seller_shipped!(tracking_number)
    self.update_attributes(:seller_shipped_at => Time.now, :seller_tracking_number => tracking_number, :status => "shipped")
  end  
  
  # seller has delivered this transaction
  def mark_as_seller_delivered!(confirmation)
    self.update_attributes(:seller_delivered_at => Time.now, :buyer_delivery_confirmation => confirmation, :status => "delivered")
  end  
  
  # buyer is happy with sale
  def mark_as_final!
    self.update_attributes(:status => "final")
  end  
  
  # removes listings and ensures they are free to be purchased again
  def remove_listings!
    self.listings.each { |l| l.free! } # free listings in this transaction
    self.listings.clear # delete listings out of this transaction
  end
  
  # creates a dummy copy of listings to be saved with rejected transaction (for tracking purposes) then frees all originals so they can be purchased again
  def reject_listings!
    self.listings.each do |l| 
      l.dup.mark_as_rejected!
      l.free! # remove listing from cart and this transaction
    end 
  end
  
end
