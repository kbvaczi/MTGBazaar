class Cart

  def initialize(session)
    @session = session
    @session[:cart] ||= Hash.new
    @session[:cart][:mtg_listing_ids] ||= []
    @session[:cart][:seller_ids] ||= []
  end
    
  def add_mtg_listing(listing)
    unless @session[:cart][:mtg_listing_ids].include?(listing.id) #don't add card if it's already in cart
      @session[:cart][:mtg_listing_ids].push(listing.id)
      @session[:cart][:seller_ids].push(listing.seller_id)
      listing.reserve!
    end
  end

  def remove_mtg_listing(listing)
    if @session[:cart][:mtg_listing_ids].include?(listing.id) #only remove card if it's actually in the cart
      @session[:cart][:mtg_listing_ids].delete(listing.id)
      @session[:cart][:seller_ids].delete_at(@session[:cart][:seller_ids].index(listing.seller_id)) #deletes one seller id out of seller id list
      listing.free!
    end
  end  
  
  def mtg_listing_ids   #returns ids of mtg_listings in cart
    return @session[:cart][:mtg_listing_ids]
  end
  
  def mtg_listings   #returns array of mtg_listing objects in cart
    if item_count > 0
      query = SmartTuple.new(" OR ")
      @session[:cart][:mtg_listing_ids].each {|id| query << ["mtg_listings.id LIKE ?", id] }
      return Mtg::Listing.where(query.compile)
    else
      return []
    end  
  end
  
  def seller_ids        #creates a unique list of seller ids
    return @session[:cart][:seller_ids].uniq
  end
  
  def total_price       #returns total price of items in cart not including shipping
    mtg_listings.to_a.sum(&:price) 
  end
  
  def item_count        #returns total count of items in cart
    mtg_listing_ids.count
  end  
  
  def listings_for_seller_id(id)
    mtg_listings.where(:seller_id => id)
  end
  
end