class CartsController < ApplicationController
  
  def show
    @cart = current_cart
  end
  
  def add_mtg_card
    current_cart.add_mtg_listing(Mtg::Listing.find(params[:id])) # add this listing to cart
    redirect_to back_path, :notice => "Card added to cart!"
    return #stop method, don't display a view
  end
  
  def remove_mtg_card
    current_cart.remove_mtg_listing(Mtg::Listing.find(params[:id])) # remove this listing from cart
    redirect_to back_path, :notice => "Card removed!"
    return #stop method, don't display a view
  end  
  
end