class CartsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def show
    set_back_path
    @orders                 = current_cart.orders.includes(:seller)
    
    # don't do this if the cart is empty
    if @orders.present?   
      @selected_order_id    = @orders.to_a.collect {|o| o.id}.include?(params[:order].to_i) ? params[:order].to_i : @orders.first.id
      @selected_order       = current_cart.orders.includes(:reservations, :seller).where("mtg_orders.id" => @selected_order_id).first
      @reservations         = @selected_order.reservations.includes(:listing => {:card => :set}).page(params[:page]).per(25)
    end
    
    respond_to do |format|
      format.html do
        if cookies[:checkout].present?
          flash.now[:notice] = "Thanks for your purchase!"      if cookies[:checkout] == "success"
          flash.now[:error]  = "Your purchase was cancelled..." if cookies[:checkout] == "failure"  
          cookies[:checkout] = ""
        end
      end
      format.js # for updating cart quantity
    end
  end
  
  def add_mtg_cards
    if current_cart.orders.count >= 5
      flash[:error] = "You can only buy from 5 different users at a time..." # ERROR - max 5 orders at a time?
      redirect_to back_path
      return      
    end
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

end