class CartsController < ApplicationController
  def show
    @cart = current_cart
  end
  
  def add_mtg_card_to_cart
    @listing = Mtg::Listing.find(params[:id])
    # find an unexecuted transaction between these two people to add this card to it found
    # if no transaction like this, then create a new one
    # if user is not logged in we can not identify buyer id at this time, we will have to remember to assign it later
    if current_user
      @transaction = Mtg::Transaction.where(:seller_id => @listing.seller.id, :cart_id => @current_cart.id).first || Mtg::Transaction.create(:buyer => current_user, :cart => @current_cart, :seller => @listing.seller)
    else
      @transaction = Mtg::Transaction.where(:seller_id => @listing.seller.id, :cart_id => @current_cart.id).first || Mtg::Transaction.create(:cart => @current_cart, :seller => @listing.seller)  
    end
    
    @transaction.listings.push(@listing) # add this listing to transaction
    redirect_to :back, :notice => "Card added to cart!"
    return
  end
  
end