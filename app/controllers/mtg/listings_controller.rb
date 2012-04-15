class Mtg::ListingsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in to make or edit listings
  before_filter :verify_owner?, :except => [:new, :create]  # prevent a user from editing another user's listings
  before_filter :verify_available?, :only => [:edit, :update, :destroy]  # don't allow users to change listings when they're in someone's cart or when they're in a transaction.
  
  def new
    session[:return_to] = request.referer #set backlink
    @listing = Mtg::Card.find(params[:card_id]).listings.build(params[:mtg_listing]) 
    respond_to do |format|
      format.html
    end    
  end
  
  def create
    @card = Mtg::Card.find(params[:card_id])
    if params[:mtg_listing] && params[:mtg_listing][:price_options] != "other"
      params[:mtg_listing][:price] = params[:mtg_listing][:price_options]
    end
    @listing = Mtg::Listing.new(params[:mtg_listing])
    if @listing.save
      @card.listings.push(@listing)                                       # add listing to the corresponding card
      current_user.mtg_listings.push(@listing)                            # this is the current user's listing
      if params[:mtg_listing][:quantity].present?
        (params[:mtg_listing][:quantity].to_i - 1).times { @listing.dup.save } #make quantity-1 copies (-1 since we already made one before)
      end  
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
    if params[:mtg_listing] && params[:mtg_listing][:price_options] != "other"
      params[:mtg_listing][:price] = params[:mtg_listing][:price_options]
    end    
    if @listing.update_attributes(params[:mtg_listing])
      redirect_to back_path, :notice => "Listing Updated!"
    else
      flash[:error] = "There were one or more errors while trying to process your request"
      render 'edit'
    end  
  end
  
  def destroy
    Mtg::Listing.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to :back , :notice => "Listing Deleted!"}
    end
  end
    
  def verify_owner?
    @listing ||= Mtg::Listing.find(params[:id])
    if @listing.seller == current_user
      return true
    else
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to :root
      return false
    end
  end
  
  def verify_available?
    @listing ||= Mtg::Listing.find(params[:id])
    if @listing.available?
      return true
    else 
      if @listing.transaction_id.present?
        flash[:error] = "This item is no longer available..."
      else
        flash[:error] = "You cannot modify this item now.  It may be in someone's cart for purchase..."
      end
      redirect_to back_path
      return false      
    end
  end
  
end
