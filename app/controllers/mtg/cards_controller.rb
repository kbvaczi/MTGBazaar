class Mtg::CardsController < ApplicationController
  
  include ApplicationHelper
  
  #caches_action :search, :layout => false, :cache_path => Proc.new { current_path }, :expires_in => 15.minutes
  #caches_action :index,  :layout => false, :cache_path => Proc.new { current_path }, :expires_in => 24.hours
  
  before_filter :set_back_path, :only => [:index, :show]
  
  # GET /mtg_cards
  def index
    @title = "Single Cards & Playsets"
    # LIST ALL CARDS BY SET    
    if params[:set]
      @set = Mtg::Set.includes(:cards => :listings).where(:code => params[:set], :active => true).first
      @mtg_cards = @set.cards.includes(:listings).page(params[:page]).per(15)
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
    @mtg_card = Mtg::Card.includes(:set, :listings => [:seller => :statistics]).where(:id => params[:id]).first
    
    if @mtg_card.dual_sided_card?
      @mtg_card = @mtg_card.dual_sided_card_front if @mtg_card.dual_sided_card_back?
      @mtg_card_back = Mtg::Card.where("mtg_cards.card_number LIKE ?", "%03d" % @mtg_card.card_number.to_i.to_s + "b").first
    end
    
    @card_variants  = Mtg::Card.joins(:set).where("mtg_cards.name LIKE ?", @mtg_card.name).select("mtg_cards.id, mtg_sets.name, mtg_sets.code").order("mtg_sets.release_date DESC")  

    filter_query    = mtg_filters_query(:card_filters => false, :seller => false, :activate_filters => params[:filter])
    
    @sort_string    = table_sort( :default => "mtg_listings.price", :price => "mtg_listings.price", :condition => "mtg_listings.condition", :language => "mtg_listings.language",
                                  :quantity => "mtg_listings.quantity_available", :seller => "LOWER(users.username)", :sales => "user_statistics.number_sales",
                                  :feedback => "user_statistics.approval_percent")                      
    
    @listings_playsets_count  = @mtg_card.listings.available.where(:playset => true).pluck(:quantity_available).inject(0) {|sum, value| sum + value}
    @listings_singles_count   = @mtg_card.listings.available.where(:playset => false).pluck(:quantity_available).inject(0) {|sum, value| sum + value}
    
    if cookies[:search_seller_id].present? && params[:filter] != "false"
      @listings_seller  = @mtg_card.listings.includes(:seller => :statistics).available.where(filter_query).where(:playset => params[:type] == "playsets" ? true : false).where("seller_id =  ?", cookies[:search_seller_id]).order(@sort_string).limit(20)
      @listings         = @mtg_card.listings.includes(:seller => :statistics).available.where(filter_query).where(:playset => params[:type] == "playsets" ? true : false).where("seller_id <> ?", cookies[:search_seller_id]).order(@sort_string).page(params[:page]).per(20)    
    else
      @listings_seller  = []
      @listings         = @mtg_card.listings.includes(:seller => :statistics).available.where(filter_query).where(:playset => params[:type] == "playsets" ? true : false).order(@sort_string).page(params[:page]).per(30)          
    end
            
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
    params[:show_level] = nil
    
    query = SmartTuple.new(" AND ")
    query << ["mtg_cards.active LIKE ?", true]
    query << ["mtg_sets.active LIKE ?", true]
    query << ["mtg_cards.name LIKE ?", "%#{params[:name]}%"] if params[:name].present? 
    unless params[:search_type].present? #user clicks on autocomplete name for specific card bypass all filters
      query << ["mtg_sets.code LIKE ?", "#{params[:set]}"] if params[:set].present?
      query << ["mana_color LIKE ?", "%W%"] if params[:white].present?
      query << ["mana_color LIKE ?", "%B%"] if params[:black].present?    
      query << ["mana_color LIKE ?", "%U%"] if params[:blue].present?
      query << ["mana_color LIKE ?", "%R%"] if params[:red].present?
      query << ["mana_color LIKE ?", "%G%"] if params[:green].present?
      query << ["rarity LIKE ?", "#{params[:rarity]}"] if params[:rarity].present?
      query << ["card_type LIKE ?", "#{params[:type]}"] if params[:type].present?
      query << ["card_subtype LIKE ?", "%#{params[:subtype]}%"] if params[:subtype].present?
      query << ["artist LIKE ?", "#{params[:artist]}"] if params[:artist].present?
      query << SmartTuple.new(" AND ").add_each(params[:abilities]) {|v| ["mtg_cards.description LIKE ?", "%#{v}%"]} if params[:abilities].present?
      if params[:language].present? or params[:options].present? or params[:seller_id].present? and params[:show] != "all"
        params[:show] = "listed" unless params[:show] == "all"
        params[:show_level] = "details"
        # language filters
        query << ["mtg_listings.language LIKE ?", params[:language]] if params[:language].present?
        # options filters
        query << ["mtg_listings.foil LIKE ?", true]     if (params[:options].include?("f") rescue false)
        query << ["mtg_listings.misprint LIKE ?", true] if (params[:options].include?("m") rescue false)
        query << ["mtg_listings.signed LIKE ?", true]   if (params[:options].include?("s") rescue false)
        query << ["mtg_listings.altart LIKE ?", true]   if (params[:options].include?("a") rescue false)
        # seller filter
        query << ["mtg_listings.seller_id = ?", params[:seller_id]] if params[:seller_id].present?
      end
      if params[:show] == "listed"
        query << ["mtg_listings.active LIKE ? AND users.active LIKE ? AND mtg_listings.quantity_available > 0", true, true]
      end
    else
      params[:type] = "" # clear search type after an exact search to prevent ajax from continuing exact searches
    end
    
    params[:page]    = params[:page] || 1 # if params[:page] # set page number if this was a search request, otherwise we keep the old one for return paths
    if params[:show] == "listed"
      @mtg_cards = Mtg::Card.joins(:listings => :seller).includes(:set, :statistics, :listings).where(query.compile).order("mtg_cards.name ASC, mtg_sets.release_date DESC").page(params[:page]).per(15)
    else
      @mtg_cards = Mtg::Card.includes(:set, :statistics).where(query.compile).order("mtg_cards.name ASC, mtg_sets.release_date DESC").page(params[:page]).per(15)
    end

    respond_to do |format|
      format.html do
        # Don't show only 1 card in search results... go directly to that card's show page if there is only one.
        # if we do this don't set back path to prevent infinite loop
        if @mtg_cards.length == 1        
          redirect_to mtg_card_path(@mtg_cards.first)
        else
          set_back_path
        end
      end
      format.js do 
        set_back_path if @mtg_cards.length > 1
      end      
    end
    
  end
  
  def autocomplete_name
    @mtg_cards = Mtg::Card.joins(:set).group(:name).where("mtg_cards.name LIKE ? AND mtg_cards.active LIKE ? AND mtg_sets.active LIKE ?", "#{params[:term]}%", true, true).limit(10).order("mtg_cards.name ASC") #grab 25.  we will display only 15, but will filter out repeats later.

    respond_to do |format|
      format.json {}  #loads view autocomplete_name.json.erb which returns json hash array of information
    end
  end
  
end
