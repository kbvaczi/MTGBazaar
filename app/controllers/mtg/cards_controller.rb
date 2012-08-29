class Mtg::CardsController < ApplicationController
  
  include ApplicationHelper
  
  # GET /mtg_cards
  def index
    @title = "MTG Cards"
    # LIST ALL CARDS BY SET    
    if params[:set]
      @mtg_cards = Mtg::Set.order("name").where(:code => params[:set], :active => true).first.cards
     @sets = []
    else
      @sets = Mtg::Set.order("name").where(:active => true)
      @mtg_cards = []
    end
  
    respond_to do |format|
      format.html #index.html.erb
    end 
  end

  # GET /mtg/cards/:id
  def show
    set_back_path
    @mtg_card = Mtg::Card.includes(:set, :listings).where(:id => params[:id].to_i).first
    @mtg_card_back = Mtg::Card.where("mtg_cards.card_number LIKE ?", "%03d" % @mtg_card.card_number.to_i.to_s + "b").first if @mtg_card.dual_sided_card?
    @card_variants = Mtg::Card.includes(:set).where("mtg_cards.name LIKE ?", @mtg_card.name)    

    # CURRENTLY IGNORING FILTERS ON LISTINGS
    query = SmartTuple.new(" AND ")
    if params[:filter] == "true"
      query << ["mtg_listings.foil LIKE ?", true] if cookies[:search_foil].present?
      query << ["mtg_listings.misprint LIKE ?", true] if cookies[:search_miscut].present?
      query << ["mtg_listings.signed LIKE ?", true] if cookies[:search_signed].present?
      query << ["mtg_listings.altart LIKE ?", true] if cookies[:search_altart].present?
      query << ["mtg_listings.seller_id LIKE ?", cookies[:search_seller_id]] if cookies[:search_seller_id].present?    
    end
    @listings = @mtg_card.listings.available.where(query.compile)
    
    case params[:sort]
      when /price/
        @listings = @listings.order("price #{sort_direction}")
      when /condition/
        @listings = @listings.order("condition #{sort_direction}")
      when /language/
        @listings = @listings.order("language #{sort_direction}")
      when /quantity/
        @listings = @listings.order("quantity #{sort_direction}")        
      when /seller/
        @listings.sort { |a,b| a.seller.username <=> b.seller.username }
      when /seller_sales/
        case params[:sort]
          when /_asc/ 
            @listings.sort { |a,b| a.seller.number_sales <=> b.seller.number_sales }        
          when /_desc/
            @listings.sort { |a,b| b.seller.number_sales <=> a.seller.number_sales }        
        end
      when /seller_feedback/
        case params[:sort]
          when /_asc/ 
            @listings.sort { |a,b| a.seller.average_rating <=> b.seller.average_rating }        
          when /_desc/
            @listings.sort { |a,b| b.seller.average_rating <=> a.seller.average_rating }        
        end    
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
      # language filters
      query << ["mtg_listings.language LIKE ? AND mtg_listings.quantity_available > 0", cookies[:search_language]] if cookies[:search_language].present?
      # options filters
      query << ["mtg_listings.foil LIKE ? AND mtg_listings.quantity_available > 0", true] if cookies[:search_foil].present?
      query << ["mtg_listings.misprint LIKE ? AND mtg_listings.quantity_available > 0", true] if cookies[:search_miscut].present?
      query << ["mtg_listings.signed LIKE ? AND mtg_listings.quantity_available > 0", true] if cookies[:search_signed].present?
      query << ["mtg_listings.altart LIKE ? AND mtg_listings.quantity_available > 0", true] if cookies[:search_altart].present?
      # seller filter
      query << ["mtg_listings.seller_id LIKE ? AND mtg_listings.quantity_available > 0", "#{cookies[:search_seller_id]}"] if cookies[:search_seller_id].present?
    end
    
    @mtg_cards = Mtg::Card.includes(:set, :listings).where(query.compile).order("mtg_cards.name ASC, mtg_sets.release_date DESC").page(params[:page]).per(20)
    
    # Don't show only 1 card in search results... go directly to that card's show page if there is only one.
    if @mtg_cards.length == 1
      redirect_to mtg_card_path(@mtg_cards.first)
    end
  end
  
  def autocomplete_name
    @mtg_cards = Mtg::Card.joins(:set).where("mtg_cards.name LIKE ? AND mtg_cards.active LIKE ? AND mtg_sets.active LIKE ?", "%#{params[:term]}%", true, true).limit(25).sort {|x,y| x[:name] <=> y[:name] } #grab 25.  we will display only 15, but will filter out repeats later.
    respond_to do |format|
      format.json {}  #loads view autocomplete_name.json.erb which returns json hash array of information
    end
  end
  
end
