class Mtg::ListingsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in to make or edit listings
  before_filter :verify_owner?, :except => [:new, :create]  # prevent a user from editing another user's listings
  before_filter :verify_not_in_cart?, :only => [:edit, :update, :destroy]  # don't allow users to change listings when they're in someone's cart or when they're in a transaction.
  
  def new
    session[:return_to] = request.referer #set backlink
    @listing = Mtg::Card.find(params[:card_id]).listings.build(params[:mtg_listing]) 
    respond_to do |format|
      format.html
    end
  end
  
  def create
    card = Mtg::Card.find(params[:card_id])
    if params[:mtg_listing] && params[:mtg_listing][:price_options] != "other"  # handle price options
      params[:mtg_listing][:price] = params[:mtg_listing][:price_options]
    end 
    @listing = Mtg::Listing.new(params[:mtg_listing])
    @listing.card_id = card.id
    @listing.seller_id = current_user.id
    duplicate_listings = Mtg::Listing.duplicate_listings_of(@listing)
    if duplicate_listings.count > 0 # there is already an identical listing, just add quantity to existing listing
      duplicate_listing = duplicate_listings.first
      duplicate_listing.increment(:quantity_available, params[:mtg_listing][:quantity].to_i)
      duplicate_listing.increment(:quantity, params[:mtg_listing][:quantity].to_i)      
      duplicate_listing.save!
      redirect_to back_path, :notice => " #{help.pluralize(params[:mtg_listing][:quantity], "Listing", "Listings")} Created..."
    elsif @listing.save
      redirect_to back_path, :notice => " #{help.pluralize(params[:mtg_listing][:quantity], "Listing", "Listings")} Created... Good Luck!"
    else
      flash[:error] = "There were one or more errors while trying to process your request"
      render 'new'
    end  
  end
  
  def edit
    session[:return_to] = request.referer #set backlink    
    @listing = Mtg::Listing.find(params[:id])
    respond_to do |format|
      format.html
    end
  end  
  
  def update
    @listing = Mtg::Listing.find(params[:id])
    # handle pricing select options to determine how to update price
    if params[:mtg_listing] && params[:mtg_listing][:price_options] != "other"
      params[:mtg_listing][:price] = params[:mtg_listing][:price_options]
    end    
    # handle updating listings before creating/destroying just in case there is a problem with update
    unless @listing.update_attributes(params[:mtg_listing])
      flash[:error] = "There were one or more errors while trying to process your request"
      render 'edit'
      return
    end
    redirect_to back_path, :notice => "Listing Updated!"
    return # don't show a view
  end
  
  def destroy
    Mtg::Listing.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to :back , :notice => "Listing Deleted!"}
    end
  end
  
  def set_active
    listing = Mtg::Listing.find(params[:id]).mark_as_active!
    respond_to do |format|
      format.html { redirect_to :back , :notice => "Listing set as active!"}
    end
  end
  
  def set_inactive
    listing = Mtg::Listing.find(params[:id]).mark_as_inactive!
    respond_to do |format|
      format.html { redirect_to :back , :notice => "Listing set as inactive!"}
    end
  end
  
  # CONTROLLER FUNCTIONS
    
  def verify_owner?
    @listing = Mtg::Listing.find(params[:id])
    if @listing.seller == current_user
      return true
    else
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to :root
      return false
    end
  end
  
  def verify_not_in_cart?
    @listing = Mtg::Listing.find(params[:id])
    unless @listing.in_cart?
      return true # this listing is available to edit
    else
      flash[:error] = "You cannot modify this item now.  It may be in someone's cart for purchase..."
    end
    redirect_to back_path
    return false  # this listing is not available to edit
  end
  
end
