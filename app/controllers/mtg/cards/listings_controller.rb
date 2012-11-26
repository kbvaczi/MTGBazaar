class Mtg::Cards::ListingsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in to make or edit listings
  before_filter :verify_user_paypal_account, :only => [:new, :create, :new_generic, :new_generic_set, :new_generic_pricing, :create_generic, 
                                                       :new_bulk_prep, :new_bulk, :create_bulk]
  before_filter :verify_owner?, :except => [:new, :create, :new_generic, :new_generic_set, :new_generic_pricing, :create_generic, 
                                            :new_bulk_prep, :new_bulk, :create_bulk]  # prevent a user from editing another user's listings
  before_filter :verify_not_in_cart?, :only => [:edit, :update, :destroy, :set_inactive]  # don't allow users to change listings when they're in someone's cart or when they're in a transaction.
  
  include ActionView::Helpers::NumberHelper  # needed for number_to_currency  
  include ActionView::Helpers::TextHelper
  include Singleton
    
  def new
    @listing = Mtg::Card.find(params[:card_id]).listings.build(params[:mtg_cards_listing]) 
    respond_to do |format|
      format.html
    end
  end
  
  def create
    card = Mtg::Card.find(params[:card_id])
    if params[:mtg_cards_listing] && params[:mtg_cards_listing][:price_options] != "other"  # handle price options
      params[:mtg_cards_listing][:price] = params[:mtg_cards_listing][:price_options]
    end 
    @listing = Mtg::Cards::Listing.new(params[:mtg_cards_listing])
    @listing.card_id = card.id
    @listing.seller_id = current_user.id
    duplicate_listings = Mtg::Cards::Listing.duplicate_listings_of(@listing)
    if duplicate_listings.count > 0 # there is already an identical listing, just add quantity to existing listing
      duplicate_listing = duplicate_listings.first
      duplicate_listing.increment(:quantity_available, params[:mtg_cards_listing][:quantity].to_i)
      duplicate_listing.increment(:quantity, params[:mtg_cards_listing][:quantity].to_i)      
      duplicate_listing.save!
      redirect_to back_path, :notice => "Listing Created..."
    elsif @listing.save
      redirect_to back_path, :notice => "Listing Created... Good Luck!"
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
    @listing = Mtg::Cards::Listing.includes(:card => :statistics).find(params[:id])
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
  
  def destroy
    Mtg::Cards::Listing.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to :back , :notice => "Listing Deleted!"}
    end
  end
  
  def set_active
    @listing.mark_as_active!
    respond_to do |format|
      format.html { redirect_to :back , :notice => "Listing set as active!"}
    end
  end
  
  def set_inactive
    @listing.mark_as_inactive!
    respond_to do |format|
      format.html { redirect_to :back , :notice => "Listing set as inactive!"}
    end
  end
  
  # NEW GENERIC IMPORT FUNCTIONS
  
  def new_generic
    set_back_path
    @listing = Mtg::Cards::Listing.new(params[:mtg_cards_listing])
    if params[:mtg_cards_listing] && params[:mtg_cards_listing][:set]
      @sets = Mtg::Set.includes(:cards).where(:active => true).where("mtg_cards.name LIKE ?", "#{params[:mtg_cards_listing][:name]}").order("release_date DESC").to_a
      @card = Mtg::Card.includes(:set, :statistics).where(:active => true).where("mtg_cards.name LIKE ? AND mtg_sets.code LIKE ?", "#{params[:mtg_cards_listing][:name]}", "#{params[:set]}").first      
    end
    respond_to do |format|
      format.html
    end
  end
  
  # updates sets select box based on name of card entered in new generic
  def new_generic_set
    @sets = Mtg::Set.includes(:cards).where(:active => true).where("mtg_cards.name LIKE ?", "#{params[:name]}").order("release_date DESC").to_a
    respond_to do |format|
      format.json { render :json => @sets.collect(&:name).zip(@sets.collect(&:code)).to_json }
    end
  end
  
  # updates cost info based on card selection
  def new_generic_pricing
    @card = Mtg::Card.includes(:set, :statistics).where(:active => true).where("mtg_cards.name LIKE ? AND mtg_sets.code LIKE ?", "#{params[:name]}", "#{params[:set]}").first
    respond_to do |format|
      format.json { render :json => [["Low (#{number_to_currency @card.statistics.price_low.dollars})", @card.statistics.price_low.dollars], ["Average (#{number_to_currency @card.statistics.price_med.dollars})", @card.statistics.price_med.dollars], ["High (#{number_to_currency @card.statistics.price_high.dollars})", @card.statistics.price_high.dollars], ["Other", "other"]].to_json }
    end
  end
  
  def create_generic
    @card = Mtg::Card.includes(:set, :statistics).where(:active => true).where("mtg_cards.name LIKE ? AND mtg_sets.code LIKE ?", "#{params[:mtg_cards_listing][:name]}", "#{params[:mtg_cards_listing][:set]}").first
    @sets = Mtg::Set.includes(:cards).where(:active => true).where("mtg_cards.name LIKE ?", params[:mtg_cards_listing][:name]).order("release_date DESC").to_a    
    if params[:mtg_cards_listing] && params[:mtg_cards_listing][:price_options] != "other"  # handle price options
      params[:mtg_cards_listing][:price] = params[:mtg_cards_listing][:price_options]
    end 
    @listing = Mtg::Cards::Listing.new(params[:mtg_cards_listing])
    @listing.card_id = @card.id
    @listing.seller_id = current_user.id
    duplicate_listings = Mtg::Cards::Listing.duplicate_listings_of(@listing)
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
      render 'new_generic'
    end      
  end
  
  def new_bulk_prep
    @listing = Mtg::Cards::Listing.new(params[:mtg_cards_listing])
  end
  
  def new_bulk
    @set = Mtg::Set.where(:code => params[:mtg_cards_listing][:set]).first
    if params[:sort] == "name"
      @cards = Mtg::Card.select(['mtg_cards.id', 'mtg_cards.name', 'mtg_cards.card_number']).joins(:set).includes(:statistics).where("mtg_sets.code LIKE ?", params[:mtg_cards_listing][:set]).order("mtg_cards.name ASC")
    else
      @cards = Mtg::Card.select(['mtg_cards.id', 'mtg_cards.name', 'mtg_cards.card_number']).joins(:set).includes(:statistics).where("mtg_sets.code LIKE ?", params[:mtg_cards_listing][:set]).order("CAST(mtg_cards.card_number AS SIGNED) ASC")
    end
  end
  
  def create_bulk
    # we have to declare these @ variables just in case we have form errors and have to render the form again... otherwise we get errors when we render the form without these declared
    @set = Mtg::Set.where(:code => params[:mtg_cards_listing][:set]).first
    if params[:sort] == "name"
      @cards = Mtg::Card.select(['mtg_cards.id', 'mtg_cards.name', 'mtg_cards.card_number']).joins(:set).includes(:listings, :statistics).where("mtg_sets.code LIKE ?", params[:mtg_cards_listing][:set]).order("name ASC")
    else
      @cards = Mtg::Card.select(['mtg_cards.id', 'mtg_cards.name', 'mtg_cards.card_number']).joins(:set).includes(:listings, :statistics).where("mtg_sets.code LIKE ?", params[:mtg_cards_listing][:set]).order("CAST(mtg_cards.card_number AS SIGNED) ASC")
    end
    array_of_listings = Array.new # blank array
    params[:sales].each do |key, value| # iterate through all of our individual listings from the bulk form
      if value[:quantity].to_i > 0 # we only care if they entered quantity > 0 for a specific card
        asking_price = (value[:price] == "other") ? value[:custom_price] : value[:price] # set price either from pre-select options or custom price if they have other selected in price options
        listing = Mtg::Cards::Listing.new(:foil => params[:mtg_cards_listing][:foil], :condition => params[:mtg_cards_listing][:condition], :language => params[:mtg_cards_listing][:language],
                                   :price => asking_price, :quantity => value[:quantity].to_i) # create the listing in memory
        listing.seller_id = current_user.id # assign seller manually since it cannot be mass assigned
        listing.card_id = key.to_i # assign card manually since it cannot be mass assigned
        # does this listing pass validation?
        if listing.valid? # yes, add to array to keep track of for later
          array_of_listings << listing # munch munch yum yum 
        else # no, redisplay form and don't do anything
          flash[:error] = "There were one or more problems with your request"
          render 'new_bulk'
          return
        end
      elsif value[:quantity].to_i < 0
        flash[:error] = "Listings cannot have a negative quantity"
        render 'new_bulk'
        return        
      end
    end
    # all listings passed validation, let's go back through our stored listings in the array and save them to database
    array_of_listings.each { |listing| listing.save } # save all the listings
    redirect_to account_listings_path, :notice => "#{pluralize(array_of_listings.count, "Listing", "Listings")} Created!"
    return #don't display a template
  end

  # CONTROLLER FUNCTIONS

  def verify_user_paypal_account
    unless current_user.account.paypal_username.present?
       flash[:error] = "A verified PayPal account is required to sell on MTGBazaar..."
       redirect_to back_path
       return false
     end
  end    
    
  def verify_owner?
    @listing = Mtg::Cards::Listing.find(params[:id])
    if @listing.seller == current_user
      return true
    else
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to back_path
      return false
    end
  end
  
  def verify_not_in_cart?
    @listing = Mtg::Cards::Listing.find(params[:id])
    unless @listing.in_cart?
      return true # this listing is available to edit
    else
      flash[:error] = "You cannot modify this item now.  It may be in someone's cart for purchase..."
    end
    redirect_to back_path
    return false  # this listing is not available to edit
  end
  
end
