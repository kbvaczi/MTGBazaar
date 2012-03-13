class Mtg::ListingsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in to make or edit listings
  before_filter :verify_owner!, :except => [:new, :create]  # prevent a user from editing another user's listings
  before_filter :verify_not_in_cart!, :only => [:edit, :update, :destroy]  # don't allow users to change listings when they're in someone's cart
  
  def new
    session[:return_to] = request.referer #set backlink
    @listing = Mtg::Card.find(params[:card_id]).listings.build(params[:mtg_listing]) 
    respond_to do |format|
      format.html
    end    
  end
  
  def create
    @listing = Mtg::Listing.new(params[:mtg_listing])
    if @listing.save
      current_user.mtg_listings << @listing                             # this is the current user's listing
      if params[:mtg_listing][:quantity].present?
        (params[:mtg_listing][:quantity].to_i - 1).times { @listing.dup.save } #make quantity-1 copies (-1 since we already made one before)
      end  
      redirect_to session[:return_to] || root_path, :notice => " #{help.pluralize(params[:mtg_listing][:quantity], "Listing", "Listings")} Created... Good Luck!"
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
    if @listing.update_attributes(params[:mtg_listing])
      redirect_to session[:return_to] || root_path, :notice => "Listing Updated!"
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
    
  def verify_owner!
    @listing = Mtg::Listing.find(params[:id])
    if @listing.seller == current_user
      return true
    else
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to :root
      return false
    end
  end
  
  def verify_not_in_cart!
    return true
  end
  
end
