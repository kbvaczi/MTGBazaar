class Mtg::Cards::EditMultipleListingsController < ApplicationController
  
  before_filter :authenticate_user!   # must be logged in to make or edit listings
  before_filter :verify_listings_selected?
  
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
    # standard implementation
    #selected_listings.each {|l| l.mark_as_active!}
    # bulk implementation
    card_ids_array = selected_listings.collect {|l| l.card_id}.uniq
    selected_listings.update_all(:active => true)
    current_user.statistics.delay.update_listings_mtg_cards_count
    Rails.logger.debug "card_ids_array #{card_ids_array.inspect}"
    Mtg::Cards::Statistics.delay.bulk_update_listing_information(card_ids_array)

    respond_to do |format|
      format.html { redirect_to back_path, :notice => "#{pluralize(selected_listings.length, "Listing", "Listings")} set as active!" }
    end
    return
    
  end
  
  def set_inactive
    # standard implementation
    # selected_listings.each {|l| l.mark_as_inactive!}
    # bulk implementation
    card_ids_array = selected_listings.collect {|l| l.card_id}.uniq
    selected_listings.update_all(:active => false)
    current_user.statistics.delay.update_listings_mtg_cards_count    
    Rails.logger.debug "card_ids_array #{card_ids_array.inspect}"    
    Mtg::Cards::Statistics.delay.bulk_update_listing_information(card_ids_array)
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "#{pluralize(selected_listings.length, "Listing", "Listings")} set as inactive!" }
    end
    return
  end
  
  def update_pricing
    listings_updated     = Mtg::Cards::Listing.bulk_update_pricing(params[:action_input], selected_listings_ids)
    listings_not_updated = selected_listings_ids.count - listings_updated
    not_updated_message  = listings_not_updated > 0 ? "  #{pluralize(listings_not_updated, "Listing", "Listings")} were not updated..." : ""    
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "Updated pricing for #{pluralize(listings_updated, "Listing", "Listings")}. #{not_updated_message}" }
    end
    
  end
  
  def delete
    Mtg::Cards::Listing.bulk_delete_listings_with_callbacks(current_user, selected_listings_ids)     
    respond_to do |format|
      format.html { redirect_to back_path, :notice => "#{pluralize(selected_listings_ids.length, "Listing", "Listings")} deleted!" }
    end
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
  
  # returns listings owned by the user that they have selected
  def selected_listings(options = {})
    options = {:select => '*'}.merge(options)
    @listings ||= current_user.mtg_listings.select(options[:select]).where(:id => (params[:edit_listings_ids].keys rescue params[:edit_listings_ids]) )
  end

  # returns IDs of listings owned by the user that they have selected  
  def selected_listings_ids
    @listing_ids ||= current_user.mtg_listings.where(:id => (params[:edit_listings_ids].keys rescue params[:edit_listings_ids])).value_of :id
  end
  
end
