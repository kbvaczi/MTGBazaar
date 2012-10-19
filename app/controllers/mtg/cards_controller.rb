class Mtg::CardsController < ApplicationController
  
  after_filter :set_back_path, :only => [:index, :show, :search]
  
  include ApplicationHelper
  
  # GET /mtg_cards
  def index
    @title = "MTG Cards"
    # LIST ALL CARDS BY SET    
    if params[:set]
      @set = Mtg::Set.includes(:cards => :listings).where(:code => params[:set], :active => true).first
      @mtg_cards = @set.cards.includes(:listings).page(params[:page]).per(25)
      @title = @title + " - #{@set.name}"
    else
      @sets = Mtg::Set.order("release_date DESC").where(:active => true)
      @mtg_cards = []
    end
  
    respond_to do |format|
      format.html #index.html.erb
    end 
  end

  # GET /mtg/cards/:id
  def show
    @mtg_card = Mtg::Card.includes(:set, :listings => [:seller => :statistics]).where(:id => params[:id].to_i).first
    if @mtg_card.dual_sided_card?
      @mtg_card = @mtg_card.dual_sided_card_front if @mtg_card.dual_sided_card_back?
      @mtg_card_back = Mtg::Card.where("mtg_cards.card_number LIKE ?", "%03d" % @mtg_card.card_number.to_i.to_s + "b").first
    end
    @card_variants = Mtg::Card.includes(:set).where("mtg_cards.name LIKE ?", @mtg_card.name).order("mtg_sets.release_date DESC")  

    query = SmartTuple.new(" AND ")
    unless params[:filter] == "false"
      query << ["mtg_listings.foil LIKE ?", true] if cookies[:search_foil].present?
      query << ["mtg_listings.misprint LIKE ?", true] if cookies[:search_miscut].present?
      query << ["mtg_listings.signed LIKE ?", true] if cookies[:search_signed].present?
      query << ["mtg_listings.altart LIKE ?", true] if cookies[:search_altart].present?
      query << ["mtg_listings.seller_id LIKE ?", cookies[:search_seller_id]] if cookies[:search_seller_id].present?    
      query << ["mtg_listings.language LIKE ?", cookies[:search_language]] if cookies[:search_language].present?          
    end
    
    sort_string = table_sort(:price => "mtg_listings.price", :condition => "mtg_listings.condition", :language => "mtg_listings.language",
                             :quantity => "mtg_listings.quantity_available", :seller => "users.username", :sales => "user_statistics.number_sales",
                             :feedback => "user_statistics.positive_feedback_count + user_statistics.neutral_feedback_count / user_statistics.number_sales")                      
    
    @listings = @mtg_card.listings.includes(:seller => :statistics).available.where(query.compile).order(sort_string)
    
    if not (@mtg_card.active or current_admin_user) # normal users cannot see inactive cards
      redirect_to back_path
      return false
    end

    respond_to do |format|
      format.html # show.html.erb
      format.js  #show.js.erb
    end

  end

  def search
    # SEARCH CARDS
    set_back_path
    query = SmartTuple.new(" AND ")
    
    query << ["mtg_cards.active LIKE ?", true]
    query << ["mtg_sets.active LIKE ?", true]
    query << ["mtg_cards.name LIKE ?", "%#{cookies[:search_name]}%"] if cookies[:search_name].present? 
    unless params[:search_type].present? #user clicks on autocomplete name for specific card bypass all filters
      query << ["mtg_sets.code LIKE ?", "#{cookies[:search_set]}"] if cookies[:search_set].present?
      query << ["mana_color LIKE ?", "%W%"] if cookies[:search_white].present?
      query << ["mana_color LIKE ?", "%B%"] if cookies[:search_black].present?    
      query << ["mana_color LIKE ?", "%U%"] if cookies[:search_blue].present?
      query << ["mana_color LIKE ?", "%R%"] if cookies[:search_red].present?
      query << ["mana_color LIKE ?", "%G%"] if cookies[:search_green].present?
      query << ["rarity LIKE ?", "#{cookies[:search_rarity]}"] if cookies[:search_rarity].present?
      query << ["card_type LIKE ?", "#{cookies[:search_type]}"] if cookies[:search_type].present?
      query << ["card_subtype LIKE ?", "%#{cookies[:search_subtype]}%"] if cookies[:search_subtype].present?
      query << ["artist LIKE ?", "#{cookies[:search_artist]}"] if cookies[:search_artist].present?
      query << SmartTuple.new(" AND ").add_each(cookies[:search_abilities].split(",")) {|v| ["mtg_cards.description LIKE ?", "%#{v}%"]} if cookies[:search_abilities].present?
      if cookies[:search_language].present? or cookies[:search_options].present? or cookies[:search_seller_id].present? or params[:show] == "listed"
        params[:show] = "listed" unless params[:show] == "all"
        # language filters
        query << ["mtg_listings.active LIKE ? AND users.active LIKE ? AND mtg_listings.quantity_available > 0", true, true]
        query << ["mtg_listings.language LIKE ?", cookies[:search_language]] if cookies[:search_language].present?
        # options filters
        query << ["mtg_listings.foil LIKE ?", true] if cookies[:search_options].present? && cookies[:search_options].include?('f')
        query << ["mtg_listings.misprint LIKE ?", true] if cookies[:search_options].present? && cookies[:search_options].include?('m')
        query << ["mtg_listings.signed LIKE ?", true] if cookies[:search_options].present? && cookies[:search_options].include?('s')
        query << ["mtg_listings.altart LIKE ?", true] if cookies[:search_options].present? && cookies[:search_options].include?('a')
        # seller filter
        query << ["mtg_listings.seller_id LIKE ?", "#{cookies[:search_seller_id]}"] if cookies[:search_seller_id].present?
      end
    else
      params[:search_type] = "" # clear search type after an exact search to prevent ajax from continuing exact searches
    end
    cookies[:search_page] = params[:page] if params[:page] # set page number if this was a search request, otherwise we keep the old one for return paths
    
    @mtg_cards = Mtg::Card.includes(:set, {:listings => :seller}, :statistics).where(query.compile).order("mtg_cards.name ASC, mtg_sets.release_date DESC").page(cookies[:search_page]).per(20)
    
    respond_to do |format|
      format.html do
        # Don't show only 1 card in search results... go directly to that card's show page if there is only one.
        redirect_to mtg_card_path(@mtg_cards.first) if @mtg_cards.length == 1
      end
      format.js {}      
    end
    
  end
  
  def autocomplete_name
    @mtg_cards = Mtg::Card.joins(:set).group(:name).where("mtg_cards.name LIKE ? AND mtg_cards.active LIKE ? AND mtg_sets.active LIKE ?", "#{params[:term]}%", true, true).limit(10).order("mtg_cards.name ASC") #grab 25.  we will display only 15, but will filter out repeats later.

    respond_to do |format|
      format.json {}  #loads view autocomplete_name.json.erb which returns json hash array of information
    end
  end
  
end
