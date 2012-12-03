class Mtg::Cards::ListingsPlaysetsController < Mtg::Cards::ListingsController
  
  before_filter :authenticate_user! # must be logged in to make or edit listings
  
  # user must have a paypal email entered on his account before performing these actions
  before_filter :verify_user_paypal_account

  # user must be owner of listing to perform an action EXCEPT for those listed here                                                     
  before_filter :verify_owner?, :except => [ :new, :create ]

  # don't allow users to change listings when they're in someone's cart or when they're in a transaction.                                            
  before_filter :verify_not_in_cart?, :only => [ :edit, :update ]  
  
  include ActionView::Helpers::NumberHelper  # needed for number_to_currency  
  include ActionView::Helpers::TextHelper
  include Singleton
    
  # ------ LISTING A SINGLE FROM CARD SHOW PAGE ------- #
    
  def new
    set_back_path
    @listing = Mtg::Cards::Listing.new(params[:mtg_cards_listing])
    if params[:mtg_cards_listing] && params[:mtg_cards_listing][:set]
      @sets = Mtg::Set.joins(:cards).active.where("mtg_cards.name LIKE ?", params[:mtg_cards_listing][:name]).order("release_date DESC").to_a    
      @card = Mtg::Card.includes(:set, :statistics).active.where("mtg_cards.name LIKE ? AND mtg_sets.code LIKE ?", "#{params[:mtg_cards_listing][:name]}", "#{params[:set]}").first      
    end
    respond_to do |format|
      format.html
    end
  end
  
  def create
    # setup variables
    @card = Mtg::Card.includes(:set, :statistics).active.where("mtg_cards.name LIKE ? AND mtg_sets.code LIKE ?", "#{params[:mtg_cards_listing][:name]}", "#{params[:mtg_cards_listing][:set]}").first
    # for redirect to new
    @sets = Mtg::Set.joins(:cards).active.where("mtg_cards.name LIKE ?", params[:mtg_cards_listing][:name]).order("release_date DESC").to_a    
    
    # handle price options
    if params[:mtg_cards_listing] && params[:mtg_cards_listing][:price_options] != "other"  
      params[:mtg_cards_listing][:price] = params[:mtg_cards_listing][:price_options]
    end 
    
    #build listing
    @listing            = Mtg::Cards::Listing.new(params[:mtg_cards_listing])
    @listing.card_id    = @card.id
    @listing.seller_id  = current_user.id
    @listing.playset    = true
    @listing.number_cards_per_listing = 4

    #handle duplicates, save
    duplicate_listings  = Mtg::Cards::Listing.duplicate_listings_of(@listing)
    if duplicate_listings.count > 0 # there is already an identical listing, just add quantity to existing listing
      duplicate_listing = duplicate_listings.first
      duplicate_listing.increment(:quantity_available, params[:mtg_cards_listing][:quantity].to_i)
      duplicate_listing.increment(:quantity, params[:mtg_cards_listing][:quantity].to_i)      
      duplicate_listing.save!
      redirect_to account_listings_path, :notice => "Listing Created!"
    elsif @listing.save
      redirect_to account_listings_path, :notice => "Listing Created!"
    else
      flash[:error] = "There were one or more errors while trying to process your request"
      render 'new'
    end
    
  end
  
  def edit
    @listing = Mtg::Cards::Listing.includes(:card => :statistics).find(params[:id])
    respond_to do |format|
      format.html
    end
  end  
  
  def update
    # setup variables    
    @listing                          = Mtg::Cards::Listing.includes(:card => :statistics).find(params[:id])
    @listing.playset                  = true
    @listing.number_cards_per_listing = 4
    
    # handle pricing select options to determine how to update price
    if params[:mtg_cards_listing] && params[:mtg_cards_listing][:price_options] != "other"
      params[:mtg_cards_listing][:price] = params[:mtg_cards_listing][:price_options]
    end 
    
    # if quantity has changed, set parameter to update quantity_available accordingly
    if params[:mtg_cards_listing] && params[:mtg_cards_listing][:quantity].to_i != @listing.quantity
      params[:mtg_cards_listing][:quantity_available] = @listing.quantity_available + (params[:mtg_cards_listing][:quantity].to_i - @listing.quantity)
    end
    
    unless @listing.update_attributes(params[:mtg_cards_listing])
      flash[:error] = "There were one or more errors while trying to process your request"
      render 'edit'
      return
    end
    
    redirect_to back_path, :notice => "Listing Updated!"
    return # don't show a view
  end
  
end
