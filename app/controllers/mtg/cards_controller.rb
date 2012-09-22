class Mtg::CardsController < ApplicationController
  
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
    set_back_path
    @mtg_card = Mtg::Card.includes(:set, :listings => [:seller => :statistics]).where(:id => params[:id].to_i).first
    @mtg_card_back = Mtg::Card.where("mtg_cards.card_number LIKE ?", "%03d" % @mtg_card.card_number.to_i.to_s + "b").first if @mtg_card.dual_sided_card?
    @card_variants = Mtg::Card.includes(:set).where("mtg_cards.name LIKE ?", @mtg_card.name)    

    query = SmartTuple.new(" AND ")
    if params[:filter] == "true"
      query << ["mtg_listings.foil LIKE ?", true] if cookies[:search_foil].present?
      query << ["mtg_listings.misprint LIKE ?", true] if cookies[:search_miscut].present?
      query << ["mtg_listings.signed LIKE ?", true] if cookies[:search_signed].present?
      query << ["mtg_listings.altart LIKE ?", true] if cookies[:search_altart].present?
      query << ["mtg_listings.seller_id LIKE ?", cookies[:search_seller_id]] if cookies[:search_seller_id].present?    
      query << ["mtg_listings.language LIKE ?", cookies[:search_language]] if cookies[:search_language].present?          
    end
    @listings = @mtg_card.listings.includes(:seller => :statistics).available.where(query.compile)
    
    case params[:sort]
      when /price/
        @listings = @listings.order("price #{sort_direction}")
      when /condition/
        @listings = @listings.order("mtg_listings.condition #{sort_direction}")
      when /language/
        @listings = @listings.order("language #{sort_direction}")
      when /quantity/
        @listings = @listings.order("quantity #{sort_direction}")        
      when /seller_sales/
        @listings = @listings.order("user_statistics.number_sales #{sort_direction}") 
      when /seller_feedback/        
        case params[:sort]
          when /_asc/ 
            @listings.sort! { |a,b| a.seller.statistics.display_approval_percent <=> b.seller.statistics.display_approval_percent }        
          when /_desc/
            @listings.sort! { |a,b| b.seller.statistics.display_approval_percent <=> a.seller.statistics.display_approval_percent }        
        end    
      when /seller/
        @listings = @listings.order("users.username #{sort_direction}")        
    end
    
    if not (@mtg_card.active or current_admin_user) # normal users cannot see inactive cards
      redirect_to (:root)
      return false
    end

    respond_to do |format|
      format.html # show.html.erb
      format.js
    end

  end

  def search
    # SEARCH CARDS
    
    query = SmartTuple.new(" AND ")
    query_listings = SmartTuple.new(" AND ")
    
    query << ["mtg_cards.active LIKE ?", true]
    query << ["mtg_sets.active LIKE ?", true]
    if params[:search_type].present? #user clicks on autocomplete name for specific card bypass all filters
      query << ["mtg_cards.name LIKE ?", "#{params[:name]}"]
    else
      query << ["mtg_cards.name LIKE ?", "%#{params[:name]}%"] if params[:name].present? 
      query << ["mtg_sets.code LIKE ?", "#{params[:set]}"] if params[:set].present?
      query << ["mana_color LIKE ?", "%#{params[:white]}%"] if params[:white].present?
      query << ["mana_color LIKE ?", "%#{params[:black]}%"] if params[:black].present?    
      query << ["mana_color LIKE ?", "%#{params[:blue]}%"] if params[:blue].present?
      query << ["mana_color LIKE ?", "%#{params[:red]}%"] if params[:red].present?
      query << ["mana_color LIKE ?", "%#{params[:green]}%"] if params[:green].present?
      query << ["rarity LIKE ?", "#{params[:rarity]}"] if params[:rarity].present?
      query << ["card_type LIKE ?", "#{params[:type]}"] if params[:type].present?
      query << ["card_subtype LIKE ?", "%#{params[:subtype]}%"] if params[:subtype].present?
      query << ["artist LIKE ?", "#{params[:artist]}"] if params[:artist].present?
      query << SmartTuple.new(" AND ").add_each(params[:abilities]) {|v| ["mtg_cards.description LIKE ?", "%#{v}%"]} if params[:abilities].present?
      
      query_listings << query.compile
      # language filters
      query_listings << ["mtg_card_statistics.listings_available > 0"]
      query_listings << ["mtg_listings.language LIKE ?", params[:language]] if params[:language].present?
      # options filters
      query_listings << ["mtg_listings.foil LIKE ?", true] if params[:options].present? && params[:options].include?('f')
      query_listings << ["mtg_listings.misprint LIKE ?", true] if params[:options].present? && params[:options].include?('m')
      query_listings << ["mtg_listings.signed LIKE ?", true] if params[:options].present? && params[:options].include?('s')
      query_listings << ["mtg_listings.altart LIKE ?", true] if params[:options].present? && params[:options].include?('a')
      # seller filter
      query_listings << ["mtg_listings.seller_id LIKE ?", "#{params[:seller_id]}"] if params[:seller_id].present?
    end
    
    if params[:seller_id].present? || params[:options].present? || params[:language].present? && params[:show] != "all"
      params[:show] = "listed"
      params[:show_level] = "details"
      @mtg_cards = Mtg::Card.includes(:set, :listings, :statistics).where(query_listings.compile).order("mtg_cards.name ASC, mtg_sets.release_date DESC").page(params[:page]).per(20)      
      @other_count = Mtg::Card.includes(:set, :statistics).where(query.compile).count    
    elsif params[:show] == "listed"
      @mtg_cards = Mtg::Card.includes(:set, :statistics).where(query_listings.compile).order("mtg_cards.name ASC, mtg_sets.release_date DESC").page(params[:page]).per(20)      
      @other_count = Mtg::Card.joins(:set, :statistics).where(query.compile).count
    else  
      @mtg_cards = Mtg::Card.includes(:set, :statistics).where(query.compile).order("mtg_cards.name ASC, mtg_sets.release_date DESC").page(params[:page]).per(20)
      @other_count = Mtg::Card.joins(:set, :statistics, :listings).where(query_listings.compile).count
    end 
    
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
