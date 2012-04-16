class CartsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def add_mtg_card
    @listing = Mtg::Listing.find(params[:id])
    if params[:quantity].to_i > 1 # user wants to buy more than one of this card
      @duplicate_listings = Mtg::Listing.duplicate_listings_of(@listing, params[:quantity]) # show me *quantity* of available duplicate listings
      if params[:quantity].to_i > @duplicate_listings.count # ERROR - user wants to buy more than is really available
        flash[:error] = "there are not that many listings available to buy"
        redirect_to back_path
        return
      else
        @duplicate_listings.each do |l|
          unless current_cart.add_mtg_listing(l) # add this listing to cart, this returns false if there is a problem
            flash[:error] = "there was a problem processing your request" # ERROR - problem while adding listing to cart?
            redirect_to back_path
            return
          end
        end
      end
    elsif not current_cart.add_mtg_listing(@listing) # add this listing to cart, this returns false if there is a problem
      flash[:error] = "there was a problem processing your request" # ERROR - problem while adding listing to cart?
      redirect_to back_path
      return
    end
    redirect_to back_path, :notice => "Card added to cart!"    
    return #stop method, don't display a view
  end
  
  # removes listing/listings from the current user's cart.  params[:id] is the id of the listing to be removed
  # params[:quantity] determines the number of duplicate listings to remove, if nil, only one listing is removed
  def remove_mtg_cards
    @card = Mtg::Listing.find(params[:id])
    if params[:quantity].to_i > 1
      @duplicates = current_cart.mtg_listings.duplicate_listings_of(@card,params[:quantity].to_i,false) #show me params[:quantity] duplicates of @card, including @card itself and unavailable cards
      @duplicates.each do |l|
        unless current_cart.remove_mtg_listing(l)
          flash[:error] = "there was a problem processing your request"
          redirect_to back_path
          return
        end
      end
    else
      unless current_cart.remove_mtg_listing(@card) # remove this listing from cart
        flash[:error] = "there was a problem processing your request"
        redirect_to back_path
        return
      end
    end
    redirect_to back_path, :notice => "Item(s) removed!"
    return #stop method, don't display a view
  end
  
  def checkout
    if current_user.account.balance >= current_cart.total_price # does user have money to purchase?
      current_cart.seller_ids.each do |id|
        @transaction = Mtg::Transaction.create(:buyer_id => current_user.id, :seller_id => id, :status => "pending", :buyer_confirmed_at => Time.now)
        current_cart.mtg_listings_for_seller_id(id).each { |l| l.mark_as_sold!(@transaction.id) } # add the listings to transaction and mark them as sold
        ApplicationMailer.send_seller_sale_notification(@transaction).deliver # send sale notification email to seller
      end
      current_user.account.balance_debit!(current_cart.total_price)  # take money out of user's balance
      current_cart.empty! # empty the shopping cart
      redirect_to back_path, :notice => "Your purchase has been submitted.  Expect seller confirmation soon."
    else
      set_back_path # set back path so that user is returned to cart after depositing
      flash[:error] = "Insufficient Balance... Please deposit funds." 
      redirect_to new_account_deposit_path # redirect to deposit page
    end
    return #stop method, don't display a view
  end
  
end