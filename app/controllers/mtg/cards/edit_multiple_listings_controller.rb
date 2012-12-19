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
    elsif params[:action_input].include? 'pricing'
      update_pricing
    else
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to back_path
    end
    return
  end
  
  def set_active
    selected_listings.each {|l| l.mark_as_active!}
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "#{pluralize(selected_listings.length, "Listing", "Listings")} set as active!" }
    end
    return
  end
  
  def set_inactive
    selected_listings.each {|l| l.mark_as_inactive!}
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "#{pluralize(selected_listings.length, "Listing", "Listings")} set as inactive!" }
    end
    return
  end
  
  def update_pricing
    listings_updated = 0
    listings_not_updated = 0
    
    selected_listings.includes(:card => :statistics).each do |listing|
      case params[:action_input].gsub("pricing_", "")
        when "low"
          pricepoint = listing.product_recommended_pricing[:price_low]
        when "high"
          pricepoint = listing.product_recommended_pricing[:price_high]
        else
          pricepoint = listing.product_recommended_pricing[:price_med]
      end
      unless listing.misprint || listing.foil || listing.altart || listing.signed || listing.language != "EN"
        listing.update_attribute(:price, pricepoint)
        listings_updated += 1
      else
        listings_not_updated += 1
      end
    end
    
    message = listings_not_updated > 0 ? "  #{pluralize(listings_not_updated, "Listing", "Listings")} were not updated..." : ""
    
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "Updated pricing for #{pluralize(listings_updated, "Listing", "Listings")}. #{message}" }
    end
    
  end
  
  def delete
    selected_listings.each {|l| l.destroy}
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "#{pluralize(selected_listings.length, "Listing", "Listings")} Deleted!" }
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
    selected_listings.each do |listing|
      if listing.seller_id != current_user.id
        flash[:error] = "You don't have permission to perform this action..."
        redirect_to back_path
        return false
      end
    end
    return true
  end
  
  def verify_not_in_cart?
    selected_listings.each do |listing|
      if listing.in_cart?
        flash[:error] = "Your listing for #{display_name(listing.card.name)} with asking price of #{number_to_currency(listing.price)} is locked due to being in a shopping cart..."
        redirect_to back_path
        return false
      end
    end
    return true
  end
  
  def selected_listings
    @listings ||= Mtg::Cards::Listing.where(:id => params[:edit_listings_ids].keys)
  end
  
  def selected_listings_ids
    params[:edit_listings_ids].keys
  end
  
end
