class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all

  before_filter :staging_authenticate        # simple HTTP authentication for production (TEMPORARY)
  before_filter :admin_panel_authenticate

  after_filter  :update_current_session_to_prevent_expiration
  #after_filter  :clear_expired_sessions
  
  include Mtg::CardsHelper
  
  protected

  # temporary HTTP authentication for production server
  # DELETE THIS METHOD WHEN SITE IS LIVE
  def staging_authenticate
    if Rails.env.staging? && request.env['PATH_INFO'] != '/admin/login' 
      authenticate_or_request_with_http_basic do |username, password|
        username == "site" && password == "test"
      end 
    end
  end
  
  def admin_panel_authenticate
    if request.env['PATH_INFO'] == '/admin/login' 
      authenticate_or_request_with_http_basic do |username, password|
        username == "admin" && password == "b4z44r2012!"
      end
    end
  end
  
  private
  
  def mobile_device?
    request.user_agent =~ /Mobile|webOS/
  end
  helper_method :mobile_device?
  
  # session only updates when changed (not accessed)... this keeps session updated if it hasn't been recently changed
  def update_current_session_to_prevent_expiration
    current_session = ActiveRecord::SessionStore::Session.find_by_session_id(request.session_options[:id])
    current_session.touch if current_session && current_session.updated_at < 10.minutes.ago
  end

  # clear expired sessions, empty their carts
  def clear_expired_sessions
    unless Rails.cache.read "clear_expired_sessions" # check timer
      Rails.cache.write "clear_expired_sessions", true, :expires_in => 10.minutes #reset timer
      Rails.logger.info "CLEARING SESSIONS"
      Session.where("updated_at < ? OR created_at < ?", 1.hours.ago, 12.hours.ago).destroy_all
      Rails.logger.info "CLEARING SESSIONS COMPLETE"
    end
    # if we cleared your session
    #unless request.session_options[:id] && ActiveRecord::SessionStore::Session.find_by_session_id(request.session_options[:id]) 
    #  reset_session # give them a new session
    #end
  end
  
  # sets the current page as the back path for following pages to return to when back_path is redirected to
  def set_back_path
    unless @new_back_path_queue.present?                                                                              # prevents this from breaking if called multiple times during one request
      current_back_path_queue = session[:back_path] || [root_path]
      @new_back_path_queue    = current_back_path_queue.dup                                                           # create a copy so the two aren't linked to the same memory address
      if current_back_path_queue.include?(current_path)                                                               # if we are revisiting an old link in the queue, let's clean up the queue (prevents infinite loops)
        @new_back_path_queue.pop(@new_back_path_queue.length - @new_back_path_queue.index(current_path))              # remove everyting in the queue visited after this link in the queue
      end                                                                 
      @new_back_path_queue.push(current_path)
      @new_back_path_queue.shift if @new_back_path_queue.length > 10                                                  # manage queue size maximum
      session[:back_path]     = @new_back_path_queue unless @new_back_path_queue == current_back_path_queue           # don't hit database again if back path queue hasn't changed
    end
  end
    
  # returns to the url where set_back_path has last been set and clears back_path
  def back_path
    unless @back_path.present?
      current_back_path_queue = @new_back_path_queue || session[:back_path] || [root_path]                      
      if current_back_path_queue.include?(current_path)
        if current_back_path_queue.length > 1
          @back_path = current_back_path_queue[current_back_path_queue.index(current_path) - 1] || root_path  
        else
          @back_path = root_path
        end
      else
        @back_path = current_back_path_queue.last || root_path
      end
    end
    @back_path
  end
  helper_method :back_path  
  
  def current_path
    @current_path ||= url_for(params.merge(:authenticity_token => nil, :utf8 => nil, :sort => nil, :sort_order => nil, :status => nil))
  end
  helper_method :current_path  
  
  # returns the current users's cart model 
  def current_cart(force = false)
    if user_signed_in?
      if session[:cart_id] && !force # current session already has a cart, let's link to it
        @current_cart ||= Cart.find(session[:cart_id])
        @current_cart.update_attribute(:user_id, current_user.id) if current_user # assign user to cart when they log in
      else # there is no cart for current session, let's create one
        @current_cart ||= Cart.create(:user_id => current_user.id) # create a cart if there isn't one already
        session[:cart_id] = @current_cart.id # link cart to current session
      end
      @current_cart
    end
  end
  helper_method :current_cart
  
  def mtg_filters_query(options_in = {})
    # setup default options and overwrite defaults with what options are sent in
    default_options = { :filter_by => "cookies", :activate_filters => true }
    options         = default_options.merge(options_in)
    # setup query
    query           = SmartTuple.new(" AND ")

    # should we filter at all?
    if options[:activate_filters] != false && options[:activate_filters] != "false" # test for string too if coming in from parameter
      
      # filtering by cookies, not parameters
      if options[:filter_by] == "cookies"

        if options[:card_filters] != false
          query << ["mtg_cards.active LIKE ?", true]
          query << ["mtg_sets.active LIKE ?", true]
          # card filters
          query << ["mtg_sets.code LIKE ?",           "#{cookies[:search_set]}"]        if cookies[:search_set].present?      && options[:set] != false
          query << ["mtg_cards.name LIKE ?",          "%#{cookies[:search_name]}%"]     if cookies[:search_name].present?     && options[:name]  != false        
          query << ["mtg_cards.mana_color LIKE ?",    "%W%"]                            if cookies[:search_white].present?    && options[:color] != false
          query << ["mtg_cards.mana_color LIKE ?",    "%B%"]                            if cookies[:search_black].present?    && options[:color] != false    
          query << ["mtg_cards.mana_color LIKE ?",    "%U%"]                            if cookies[:search_blue].present?     && options[:color] != false
          query << ["mtg_cards.mana_color LIKE ?",    "%R%"]                            if cookies[:search_red].present?      && options[:color] != false
          query << ["mtg_cards.mana_color LIKE ?",    "%G%"]                            if cookies[:search_green].present?    && options[:color] != false
          query << ["mtg_cards.rarity LIKE ?",        "#{cookies[:search_rarity]}"]     if cookies[:search_rarity].present?   && options[:rarity] != false
          query << ["mtg_cards.card_type LIKE ?",     "#{cookies[:search_type]}"]       if cookies[:search_type].present?     && options[:type] != false
          query << ["mtg_cards.card_subtype LIKE ?",  "%#{cookies[:search_subtype]}%"]  if cookies[:search_subtype].present?  && options[:subtype] != false
          query << ["mtg_cards.artist LIKE ?",        "#{cookies[:search_artist]}"]     if cookies[:search_artist].present?   && options[:artist] != false
          query << SmartTuple.new(" AND ").add_each(cookies[:search_abilities].split(",")) {|v| ["mtg_cards.description LIKE ?", "%#{v}%"]} if cookies[:search_abilities].present? && options[:abilities] != false
        end
        if options[:listing_filters] != false
          # language filters
          query << ["mtg_listings.language LIKE ?", cookies[:search_language]]          if cookies[:search_language].present? && options[:language] != false
          # options filters
          if options[:options] != false
            query << ["mtg_listings.foil LIKE ?",     true]                               if cookies[:search_foil].present?     && cookies[:search_foil]
            query << ["mtg_listings.misprint LIKE ?", true]                               if cookies[:search_miscut].present?   && cookies[:search_miscut]
            query << ["mtg_listings.signed LIKE ?",   true]                               if cookies[:search_signed].present?   && cookies[:search_signed]
            query << ["mtg_listings.altart LIKE ?",   true]                               if cookies[:search_altart].present?   && cookies[:search_altart]
          end
          # seller filter
          query << ["mtg_listings.seller_id LIKE ?", "#{cookies[:search_seller_id]}"]   if cookies[:search_seller_id].present? && options[:seller] != false
        end
      
      else # end filtering by cookies, start filtering by parameters
      
        if options[:card_filters] != false
          query << ["mtg_cards.active LIKE ?", true]
          query << ["mtg_sets.active LIKE ?", true]          
          # card filters
          query << ["mtg_cards.name LIKE ?",          "%#{params[:name]}%"]             if params[:name].present?             && options[:name]  != false
          query << ["mtg_sets.code LIKE ?",           "#{params[:set]}"]                if params[:set].present?              && options[:set]   != false
          query << ["mtg_cards.mana_color LIKE ?",    "%W%"]                            if params[:white].present?            && options[:color] != false
          query << ["mtg_cards.mana_color LIKE ?",    "%B%"]                            if params[:black].present?            && options[:color] != false    
          query << ["mtg_cards.mana_color LIKE ?",    "%U%"]                            if params[:blue].present?             && options[:color] != false
          query << ["mtg_cards.mana_color LIKE ?",    "%R%"]                            if params[:red].present?              && options[:color] != false
          query << ["mtg_cards.mana_color LIKE ?",    "%G%"]                            if params[:green].present?            && options[:color] != false
          query << ["mtg_cards.rarity LIKE ?",        "#{params[:rarity]}"]             if params[:rarity].present?           && options[:rarity] != false
          query << ["mtg_cards.card_type LIKE ?",     "#{params[:type]}"]               if params[:type].present?             && options[:type] != false
          query << ["mtg_cards.card_subtype LIKE ?",  "%#{params[:subtype]}%"]          if params[:subtype].present?          && options[:subtype] != false
          query << ["mtg_cards.artist LIKE ?",        "#{params[:artist]}"]             if params[:artist].present?           && options[:artist] != false
          query << SmartTuple.new(" AND ").add_each(params[:abilities]) {|v| ["mtg_cards.description LIKE ?", "%#{v}%"]} if params[:abilities].present? && options[:abilities] != false
        end
        if options[:listing_filters] != false
          # language filters
          query << ["mtg_listings.language LIKE ?", params[:language]]                  if params[:language].present?         && options[:language] != false
          # options filters
          if options[:options] != false
            query << ["mtg_listings.foil LIKE ?", true]                                 if (params[:options].include?("f") rescue false)
            query << ["mtg_listings.misprint LIKE ?", true]                             if (params[:options].include?("m") rescue false)
            query << ["mtg_listings.signed LIKE ?", true]                               if (params[:options].include?("s") rescue false)
            query << ["mtg_listings.altart LIKE ?", true]                               if (params[:options].include?("a") rescue false)
          end
          # seller filter
          query << ["mtg_listings.seller_id LIKE ?", "#{params[:seller_id]}"]           if params[:seller_id].present?        && options[:seller] != false
        end      

      end # filtering by parameters
      
    end
    query.compile
  end
  helper_method :mtg_filters_query
  
  def minimum_price_for_checkout
    5.00
  end
  helper_method :minimum_price_for_checkout
    
  def table_sort(options = {})
    selected_sort = options[params[:sort].parameterize.underscore.to_sym] rescue nil
    if selected_sort
      sort_string = "#{selected_sort} #{params[:sort_order] == "asc" ? "ASC" : "DESC"}" 
    else
      if options[:default]
        sort_string = "#{options[:default]} #{options[:default_order] || "ASC"}" 
      else
        nil
      end
    end
  end

  
end

=begin

["darnovo@gmail.com", "ken@mtgbazaar.com", "shennissar@hotmail.com", "johnnyvaleriote@gmail.com", "onislave@gmail.com", "chaosevoker@gmail.com", "nathanlilly@lycos.com", "drshakar@live.com", "anthonysirfalot@yahoo.com", "azariah@azariah.net", "taylor_w87@yahoo.com", "cruzing2001@yahoo.com", "fusionmod@gmail.com", "marcrajotte@shaw.ca", "customerservice@jaxcardsingles.com", "tgpsychoguy@aol.com", "dragbait@yahoo.com", "remeltphoto@gmail.com", "jefemats@hotmail.com", "schaefer.sm@gmail.com", "info@fatogre.com", "schm9400@gmail.com", "mritak@hotmail.com", "shwn@bol.com.br", "sandrete66@gmail.com", "ilovechristiwu@gmail.com", "hugodanobeitia@hotmail.com", "chadwick.j.hewitt@gmail.com", "juan.the-oath@hotmail.com", "fchenard@gmail.com"]

=end
