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
        transaction = Mtg::Transaction.create(:buyer_id => current_user.id, :seller_id => id, :status => "pending", :buyer_confirmed_at => Time.now) #create the transaction
        current_cart.reservations.includes(:listing).where("mtg_listings.seller_id" => id).each do |reservation| # find all reservations for this seller
          transaction.create_item_from_reservation(reservation) # create transaction items based on these reservations
          reservation.purchased! # update listing quantity and destroy this reservation
        end
        ApplicationMailer.send_seller_sale_notification(transaction).deliver # send sale notification email to seller
      end
      current_user.account.balance_debit!(current_cart.total_price)  # take money out of user's balance
      current_cart.update_cache! # empty the shopping cart
      redirect_to back_path, :notice => "Your purchase has been submitted.  Expect seller confirmation soon."
    else
      set_back_path # set back path so that user is returned to cart after depositing
      flash[:error] = "Insufficient Balance... Please deposit funds." 
      redirect_to new_account_deposit_path # redirect to deposit page
    end
    return #stop method, don't display a view
  end
  
end