class Cart < ActiveRecord::Base
  has_many :mtg_transactions, :class_name  => "Mtg::Transaction"
  has_many :mtg_listings, :through => :mtg_transactions, :source => :listings
  
  def total_price
    # convert to array so it doesn't try to do sum on database directly
    mtg_listings.to_a.sum(&:price)
  end

  
end