class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all

  before_filter :production_authenticate        # simple HTTP authentication for production (TEMPORARY)
  before_filter :clear_expired_sessions
  
  include Mtg::CardsHelper
  
  protected

  # temporary HTTP authentication for production server
  # DELETE THIS METHOD WHEN SITE IS LIVE
  def production_authenticate
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        username == "site" && password == "test"
      end 
    end
  end
  
  def clear_expired_sessions
    unless Rails.cache.read "clear_expired_sessions" # check timer
      Rails.cache.write "clear_expired_sessions", true, :expires_in => 10.minutes #reset timer
      Rails.logger.info "CLEARING SESSIONS"
      Session.where(["updated_at < ? OR created_at < ?", 30.minutes.ago, 12.hours.ago]).each {|s| s.destroy}
      Rails.logger.info "CLEARING SESSIONS COMPLETE"
    end
    # if we cleared your session
    unless request.session_options[:id] && ActiveRecord::SessionStore::Session.find_by_session_id(request.session_options[:id]) 
      reset_session # give them a new session
      flash[:error] = "For security purposes, your session was timed out..." # tell them their session was timed out
    end
  end

  # checks to see if the current logged in user is banned.  logs out and flashes warning if so.
  def user_banned?                              
    if user_signed_in? && current_user.banned?
      sign_out current_user
      flash[:error] = "This account has been suspended..."
      root_path
    end
  end
  
  # sets the current page as the back path for following pages to return to when back_path is redirected to
  def set_back_path
    session[:return_to] = request.fullpath
  end
  
  # returns to the url where set_back_path has last been set and clears back_path
  def back_path
    return_path = session[:return_to] || root_path
    session[:return_to] = nil
    return return_path
  end
  
  # returns the current users's cart model 
  helper_method :current_cart
  def current_cart(force = false)
    if user_signed_in?
      if session[:cart_id] && !force # current session already has a cart, let's link to it
        @current_cart ||= Cart.find(session[:cart_id]) 
        #@current_cart.update_attribute(:user_id, current_user.id) if current_user # assign user to cart when they log in
      else # there is no cart for current session, let's create one
        @current_cart ||= Cart.create(:user_id => current_user.id) # create a cart if there isn't one already
        session[:cart_id] = @current_cart.id # link cart to current session
      end
      @current_cart
    end
  end
  
  def build_mtg_query(options = {})
    query = SmartTuple.new(" AND ")
    query << ["mtg_sets.code LIKE ?", "#{cookies[:search_set]}"] if cookies[:search_set].present? && options[:set] != false
    query << ["mtg_cards.mana_color LIKE ?", "%#{cookies[:search_white]}%"] if cookies[:search_white].present? && options[:color] != false
    query << ["mtg_cards.mana_color LIKE ?", "%#{cookies[:search_black]}%"] if cookies[:search_black].present? && options[:color] != false    
    query << ["mtg_cards.mana_color LIKE ?", "%#{cookies[:search_blue]}%"] if cookies[:search_blue].present? && options[:color] != false
    query << ["mtg_cards.mana_color LIKE ?", "%#{cookies[:search_red]}%"] if cookies[:search_red].present? && options[:color] != false
    query << ["mtg_cards.mana_color LIKE ?", "%#{cookies[:search_green]}%"] if cookies[:search_green].present? && options[:color] != false
    query << ["mtg_cards.rarity LIKE ?", "#{cookies[:search_rarity]}"] if cookies[:search_rarity].present? && options[:rarity] != false
    query << ["mtg_cards.card_type LIKE ?", "#{cookies[:search_type]}"] if cookies[:search_type].present? && options[:type] != false
    query << ["mtg_cards.card_subtype LIKE ?", "%#{cookies[:search_subtype]}%"] if cookies[:search_subtype].present? && options[:subtype] != false
    query << ["mtg_cards.artist LIKE ?", "#{cookies[:search_artist]}"] if cookies[:search_artist].present? && options[:artist] != false
    query << SmartTuple.new(" AND ").add_each(cookies[:search_abilities]) {|v| ["mtg_cards.description LIKE ?", "%#{v}%"]} if cookies[:search_abilities].present? && options[:abilities] != false
    # language filters
    query << ["mtg_listings.language LIKE ?", cookies[:search_language]] if cookies[:search_language].present? && options[:language] != false
    # options filters
    query << ["mtg_listings.foil LIKE ?", true] if cookies[:search_options].present? && cookies[:search_options].include?('f') && options[:options] != false
    query << ["mtg_listings.misprint LIKE ?", true] if cookies[:search_options].present? && cookies[:search_options].include?('m') && options[:options] != false
    query << ["mtg_listings.signed LIKE ?", true] if cookies[:search_options].present? && cookies[:search_options].include?('s') && options[:options] != false
    query << ["mtg_listings.altart LIKE ?", true] if cookies[:search_options].present? && cookies[:search_options].include?('a') && options[:options] != false
    # seller filter
    query << ["mtg_listings.seller_id LIKE ?", "#{cookies[:search_seller_id]}"] if cookies[:search_seller_id].present? && options[:seller] != false
    query.compile
  end
    
end
