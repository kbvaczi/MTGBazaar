class Mtg::ListingsController < ApplicationController
  
  before_filter :authenticate_user!
  
  def new
    session[:return_to] = request.referer #set backlink
    if params[:mtg_listing].present? #render show to prepopulate forms if necessary
      render 'edit'
      return
    end
    @listing = Mtg::Card.find(params[:id]).listings.build

    respond_to do |format|
      format.html
    end    
  end
  
  def edit
    @listing = Mtg::Card.find(params[:id]).listings.build(params[:mtg_listing])
  end  
  
  def create
    @listing = Mtg::Card.find(params[:id]).listings.build(params[:mtg_listing])
    if @listing.save
      current_user.mtg_listings << @listing                             # this is the current user's listing
      if params[:mtg_listing][:quantity].present?
        (params[:mtg_listing][:quantity].to_i - 1).times { @listing.dup.save } #make quantity-1 copies (-1 since we already made one before)
      end  
      
      redirect_to session[:return_to] || root_path, :notice => "Listing Successful... Good Luck!"
    else
      flash[:error] = "There were one or more errors while trying to process your request"
      render 'edit'
    end  
  end
    
end
