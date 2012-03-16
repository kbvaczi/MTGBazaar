class Cart

  include ActionView::Helpers::NumberHelper  # needed for number_to_currency  
  
  def initialize(session)
    @session = session
    @session[:cart] ||= Hash.new
    @session[:cart][:total_price] ||= 0
    @session[:cart][:seller_ids] ||= Hash.new
  end
    
  def add_mtg_listing(listing)
    if @session[:cart][:seller_ids].include?(listing.seller_id) # if seller already has something in this cart
      return false if @session[:cart][:seller_ids][listing.seller_id].include?(listing.id) # don't add card if it's already in cart
      @session[:cart][:seller_ids][listing.seller_id].push(listing.id) # add card to existing seller      
    else # else listing's seller doesn't have a card in this cart
      @session[:cart][:seller_ids][listing.seller_id] = [ listing.id ] #create card for new seller
    end
    listing.reserve! # reserve this listing so nobody else can add it
    @session[:cart][:total_price] += listing.price.dollars # keep track of cart's total price
    return true # success
  end

  def remove_mtg_listing(listing)
    if @session[:cart][:seller_ids].include?(listing.seller_id) && @session[:cart][:seller_ids][listing.seller_id].include?(listing.id) # if card is in the cart
      @session[:cart][:seller_ids][listing.seller_id].delete(listing.id) # remove listing from cart
      @session[:cart][:seller_ids].delete(listing.seller_id) if @session[:cart][:seller_ids][listing.seller_id].empty? # remove this seller from cart as he/she no longer has any items here
      listing.free! # make this listing available to others to buy
      @session[:cart][:total_price] -= listing.price.dollars # keep track of cart's total price      
      return true # success
    else
      return false # this card is not in cart
    end
  end  
  
  def mtg_listing_ids   #returns array of ids of mtg_listings in cart
    @session[:cart][:seller_ids].values.flatten
  end
  
  def seller_ids        #creates a unique list of seller ids
    @session[:cart][:seller_ids].keys
  end
  
  def mtg_listings   #returns activerecord::relation of mtg_listing objects in cart
    Mtg::Listing.by_id(mtg_listing_ids)
  end

  def mtg_listings_for_seller_id(id)
    Mtg::Listing.by_id(@session[:cart][:seller_ids][id])
  end
  
  def total_price       #returns total price of items in cart not including shipping
    @session[:cart][:total_price]
  end
  
  def item_count        #returns total count of items in cart
    @session[:cart][:seller_ids].values.flatten.length
  end  
  
  def empty!            #removes all listings from cart
    mtg_listings.each {|l| remove_mtg_listing(l)}
  end
  
end


# This is an alternative implementation for Cart which stores the entire activerecord object in session...
# This is not being used currently
=begin
class Cart_Model

  def initialize(session)
    @session = session
    @session[:cart] ||= Hash.new
    @session[:cart][:seller_ids] ||= Hash.new
  end
    
  def add_mtg_listing(listing)

    if @session[:cart][:seller_ids].include?(listing.seller_id) # seller already has something in this cart
      return false if @session[:cart][:seller_ids][listing.seller_id].include?(listing) # don't add card if it's already in cart
      @session[:cart][:seller_ids][listing.seller_id].push(listing) # add card to existing seller      
    else # listing's seller doesn't have a card in this cart
      @session[:cart][:seller_ids][listing.seller_id] = [ listing ] #create card for new seller
    end
    listing.reserve! # reserve this listing so nobody else can add it
    return true # success
    
    #unless @session[:cart][:mtg_listing_ids].include?(listing.id) 
    #  @session[:cart][:mtg_listing_ids].push(listing.id)
    #  @session[:cart][:seller_ids].push(listing.seller_id)
    #  listing.reserve!
    # end
  end

  def remove_mtg_listing(listing)
    if @session[:cart][:seller_ids].include?(listing.seller_id) && @session[:cart][:seller_ids][listing.seller_id].include?(listing) # if card is in the cart
      @session[:cart][:seller_ids][listing.seller_id].delete(listing) # remove listing from cart
      listing.free! # make this listing available to others to buy
      @session[:cart][:seller_ids].delete(listing.seller_id) if @session[:cart][:seller_ids][listing.seller_id].empty? # remove this seller from cart as he/she no longer has any items here
      return true # success
    else
      return false # this card is not in cart
    end

    
    #if @session[:cart][:mtg_listing_ids].include?(listing.id) #only remove card if it's actually in the cart
    #  @session[:cart][:mtg_listing_ids].delete(listing.id)
    #  @session[:cart][:seller_ids].delete_at(@session[:cart][:seller_ids].index(listing.seller_id)) #deletes one seller id out of seller id list
    #  listing.free!
    #end
  end  
  
  def mtg_listing_ids   #returns array of ids of mtg_listings in cart
    @session[:cart][:seller_ids].values.flatten.collect{ |l| l.id }
    #return @session[:cart][:mtg_listing_ids]
  end
  
  def mtg_listings   #returns array of mtg_listing objects in cart
    if item_count > 0
      query = SmartTuple.new(" OR ")
      mtg_listing_ids.each {|id| query << ["mtg_listings.id LIKE ?", id] }
      return Mtg::Listing.where(query.compile)
    else
      return []
    end  
  end
  
  def seller_ids        #creates a unique list of seller ids
    @session[:cart][:seller_ids].keys
    #return @session[:cart][:seller_ids].uniq
  end
  
  def total_price       #returns total price of items in cart not including shipping
    @session[:cart][:seller_ids].values.flatten.collect{ |l| l.price.dollars }.inject(0){|sum,item| sum + item}
  end
  
  def item_count        #returns total count of items in cart
    @session[:cart][:seller_ids].values.flatten.length
  end  
  
  def listings_for_seller_id(id)
    @session[:cart][:seller_ids][id]
  end
  
end
=end