class CartsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def show
    set_back_path
    @orders = current_cart.orders.includes(:reservations, :listings, :seller)
    
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end
  
  def add_mtg_cards
    listing = Mtg::Cards::Listing.find(params[:id])
    unless current_cart.add_mtg_listing(listing, params[:quantity].to_i) # add this listing to cart, this returns false if there is a problem
      flash[:error] = "there was a problem processing your request" # ERROR - problem while adding listing to cart?
      redirect_to back_path
      return
    end
    redirect_to back_path, :notice => "#{params[:quantity].to_i} cards added to cart!"    
    return #stop method, don't display a view
  end
  
  # removes listing/listings from the current user's cart.  params[:id] is the id of the listing to be removed
  # params[:quantity] determines the number of duplicate listings to remove, if nil, only one listing is removed
  def remove_mtg_cards
    reservation = Mtg::Reservation.find(params[:id])
    unless current_cart.remove_mtg_listing(reservation, params[:quantity].to_i) # remove this listing from cart
      flash[:error] = "there was a problem processing your request"
      redirect_to back_path
      return
    end
    redirect_to back_path, :notice => "Item(s) removed!"
    return #stop method, don't display a view
  end
  
  def update_quantity_mtg_cards
    reservation = Mtg::Reservation.find(params[:id])
    current_quantity = reservation.quantity #count the number of duplicates to this card in cart
    if params[:quantity].to_i > current_quantity and params[:quantity].to_i > 0 #the user wants to add more cards
      quantity_to_add = params[:quantity].to_i - current_quantity
      unless current_cart.add_mtg_listing(reservation.listing, quantity_to_add)
        flash[:error] = "there was a problem processing your request"
        redirect_to back_path
        return
      end
    elsif params[:quantity].to_i < current_quantity and params[:quantity].to_i >= 0# the user wants to remove cards
      quantity_to_remove = current_quantity - params[:quantity].to_i
      unless current_cart.remove_mtg_listing(reservation, quantity_to_remove)
        flash[:error] = "there was a problem processing your request"
        redirect_to back_path
        return
      end        
    else # the user wants to keep number of cards the same
      redirect_to back_path # do nothing
      return
    end # standard cases satisfied
    redirect_to back_path, :notice => "Item quantity updated..."
    return #stop method, don't display a view
  end
  
  def checkout_successful
    order = current_cart.orders.includes(:reservations).where(:id => params[:id]).first
    transaction = Mtg::Transaction.new(:buyer => current_user, :seller_id => order.seller_id, :status => "pending", :buyer_confirmed_at => Time.now) #create the transaction
    order.reservations.each { |r| transaction.build_item_from_reservation(r) } # create transaction items based on these reservations
    if not transaction.valid?
      flash[:error] = "There was a problem processing your request" 
      redirect_to back_path
      return
    end  
    # once we've verified everything in the cart we can save everything to the database
    transaction.save # save each transaction        
    order.reservations.each { |r| r.purchased! } # update listing quantity and destroy each reservation for this transaction
    ApplicationMailer.seller_sale_notification(transaction).deliver # send sale notification email to seller
    ApplicationMailer.buyer_checkout_confirmation(transaction).deliver # send sale notification email to seller        
    current_cart.update_cache # empty the shopping cart
    redirect_to root_path, :notice => "Your purchase request has been submitted."  
    return #stop method, don't display a view
  end


end