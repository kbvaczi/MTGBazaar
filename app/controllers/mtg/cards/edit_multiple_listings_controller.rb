class Mtg::Cards::EditMultipleListingsController < ApplicationController
  
  before_filter :authenticate_user!   # must be logged in to make or edit listings
  before_filter :verify_listings_selected?
  before_filter :verify_owner?        # prevent a user from editing another user's listings
  before_filter :verify_not_in_cart?  # don't allow users to change listings when they're in someone's cart or when they're in a transaction.

  
  include ActionView::Helpers::NumberHelper  # needed for number_to_currency  
  include ActionView::Helpers::TextHelper
  #include Singleton
  
  def process_request
    if params[:action_input] == 'active'
      set_active
    elsif params[:action_input] == 'inactive'
      set_inactive
    elsif params[:action_input] == 'delete'
      delete
    else
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to back_path
    end
    return
  end
  
  def set_active
    @listings.each {|l| l.mark_as_active!}
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "#{pluralize(@listings.length, "Listing", "Listings")} set as active!" }
    end
    return
  end
  
  def set_inactive
    @listings.each {|l| l.mark_as_inactive!}
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "#{pluralize(@listings.length, "Listing", "Listings")} set as inactive!" }
    end
    return
  end
  
  def delete
    @listings.each {|l| l.destroy}
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "#{pluralize(@listings.length, "Listing", "Listings")} Deleted!" }
    end
    return
  end
  
  # CONTROLLER FUNCTIONS
    
  def verify_listings_selected?
    if (params[:edit_listings_ids].length < 0 rescue true)
      flash[:error] = "No listings selected..."
      redirect_to back_path
      return false
    end
    return true
  end
  
  def verify_owner?
    @listings ||= Mtg::Cards::Listing.find(params[:edit_listings_ids].keys)
    @listings.each do |listing|
      if listing.seller_id != current_user.id
        flash[:error] = "You don't have permission to perform this action..."
        redirect_to back_path
        return false
      end
    end
    return true
  end
  
  def verify_not_in_cart?
    @listings ||= Mtg::Cards::Listing.find(params[:edit_listings_ids].keys)
    @listings.each do |listing|
      if listing.in_cart?
        flash[:error] = "Your listing for #{display_name(listing.card.name)} with asking price of #{number_to_currency(listing.price)} is locked due to being in a shopping cart..."
        redirect_to back_path
        return false
      end
    end
    return true
  end
  
end
