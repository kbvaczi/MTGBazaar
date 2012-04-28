class Mtg::Transaction < ActiveRecord::Base
  self.table_name = 'mtg_transactions'
  
  belongs_to :seller,   :class_name => "User"
  belongs_to :buyer,    :class_name => "User"
  has_many   :items,    :class_name => "Mtg::TransactionItem", :foreign_key => "transaction_id"
  
  # creates a unique transaction number based on transaction ID
  def transaction_number
    "MTG-#{(self.id + 10000).to_s(36).rjust(6,"0").upcase}"
  end
  
  # returns the total value of a transaction
  def total_value
    Mtg::TransactionItem.by_id(item_ids).sum("mtg_transaction_items.price * mtg_transaction_items.quantity").to_f / 100
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
  
  # creates a dummy copy of listings to be saved with rejected transaction (for tracking purposes) then frees all originals so they can be purchased again
  def reject_items!
    self.items.each do |i|
      i.update_attribute(:rejected_at, Time.now)
      self.create_listing_from_item(i)
    end
  end
  
  def create_item_from_reservation(reservation)
    item = Mtg::TransactionItem.new( :quantity => reservation.quantity,
                                     :price => reservation.listing.price,
                                     :condition => reservation.listing.condition,
                                     :language => reservation.listing.language,
                                     :description => reservation.listing.description,
                                     :altart => reservation.listing.altart,
                                     :misprint => reservation.listing.misprint,
                                     :foil => reservation.listing.foil,
                                     :signed => reservation.listing.signed )
    item.card_id = reservation.listing.card_id
    item.buyer_id = self.buyer_id
    item.seller_id = self.seller_id
    item.transaction_id = self.id
    item.save
  end
  
  def create_listing_from_item(item)
    listing = Mtg::Listing.new(      :quantity => item.quantity,
                                     :price => item.price,
                                     :condition => item.condition,
                                     :language => item.language,
                                     :description => item.description,
                                     :altart => item.altart,
                                     :misprint => item.misprint,
                                     :foil => item.foil,
                                     :signed => item.signed )
    listing.card_id = item.card_id
    listing.seller_id = self.seller_id
    duplicate = Mtg::Listing.duplicate_listings_of(listing).first
    if duplicate.present? # there is already a duplicate listing, just update quantity of cards
      duplicate.update_attributes(  :quantity => duplicate.quantity + item.quantity, 
                                    :quantity_available => duplicate.quantity_available + item.quantity )
    else # there is no duplicate listing, create a new one from item
      listing.save
    end
  end
  
end
