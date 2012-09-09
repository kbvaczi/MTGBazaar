class CartsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def add_mtg_cards
    listing = Mtg::Listing.find(params[:id])
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
  
  def checkout
    if current_user.account.balance >= current_cart.total_price # does user have money to purchase?
      current_cart.seller_ids.each do |id| #create a transaction for each seller
        transaction = Mtg::Transaction.new(:buyer => current_user, :seller_id => id, :status => "pending", :buyer_confirmed_at => Time.now) #create the transaction
        reservation_group = current_cart.reservations.includes(:listing).where("mtg_listings.seller_id" => id) # find reservations from this seller
        reservation_group.each { |r| transaction.build_item_from_reservation(r) } # create transaction items based on these reservations
        if transaction.save
          reservation_group.each { |r| r.purchased! } # update listing quantity and destroy this reservation
          #TODO: Delayed job emails
          ApplicationMailer.send_seller_sale_notification(transaction).deliver # send sale notification email to seller
          ApplicationMailer.send_buyer_checkout_confirmation(transaction).deliver # notify buyer that the sale has been confirmed               
          current_cart.update_cache! # empty the shopping cart
          redirect_to root_path, :notice => "Your purchase request has been submitted."          
        else  
          flash[:error] = "#{transaction.errors.full_messages}There was a problem processing your request" 
          redirect_to back_path
          return
        end
      end
    else
      set_back_path # set back path so that user is returned to cart after depositing
      flash[:error] = "Insufficient Balance... Please deposit funds." 
      redirect_to new_account_deposit_path # redirect to deposit page
    end
    return #stop method, don't display a view
  end
  
end