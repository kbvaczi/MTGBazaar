class Mtg::Reservation < ActiveRecord::Base
  self.table_name = 'mtg_reservations'    

  belongs_to :listing,      :class_name => "Mtg::Cards::Listing",                          :foreign_key => "listing_id"
  belongs_to :order,        :class_name => "Mtg::Order",                            :foreign_key => "order_id"
  has_one    :seller,       :class_name => "User",          :through => :listing
  has_one    :card,         :class_name => "Mtg::Card",     :through => :listing
  has_one    :cart,         :class_name => "Cart",          :through => :order  
  
  attr_accessible :listing_id, :order_id, :quantity, :cards_quantity
  
  ##### ------ VALIDATIONS ----- #####
  
  validates :quantity,  :numericality => {:greater_than_or_equal_to => 0, :less_than => 10000}  #quantity must be between 0 and 10000

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
    this_card = self.listing.card                               # remember listing's card just in case we destroy it
    if self.listing.quantity > self.quantity
      self.listing.decrement(:quantity, self.quantity).save       # update listing quantities
    else  
      self.listing.destroy                                        # listings can't have 0 quantity, so let's just destroy it
    end
    # we will handle updating card statistics via bulk update independnet of this action
    #this_card.statistics.update!                                  # update card statistics
    self.destroy                                                  # we no longer need this reservation, let's get rid of it
  end

  def product_name(truncate = false)
    product = self.listing
    product_type = ""
    product_name = ""
    if product.class.name == "Mtg::Cards::Listing"
      product_type = "Playset" if product.playset
      product_name = product.card.name
    elsif product.class.name == "Mtg::Sets::Listing"
      product_type = "Full Set"
      product_name = product.set.name
    else
      product_name = "Unknown"
    end
    if product_type != ""
      if truncate
        "#{product_type}: #{product_name.truncate(30, :omission => "...")}"
      else
        "#{product_type}: #{product_name}"
      end
    else
      if truncate
        product_name.html_safe.truncate(30, :omission => "...")
      else
        product_name.html_safe
      end
    end
  end

  ##### ------ PRIVATE METHODS ----- #####          
  private
  
end