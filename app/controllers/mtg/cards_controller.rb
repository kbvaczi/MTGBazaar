class Mtg::CardsController < ApplicationController
  
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

  # GET /mtg/cards/1
  def show
    create_back_path
    @mtg_card = Mtg::Card.find(params[:id])
    @mtg_card_back = Mtg::Card.joins(:set).where("card_number LIKE ? AND mtg_sets.code LIKE ?", "%03d" % @mtg_card.card_number.to_i.to_s + "b", @mtg_card.set.code).first if @mtg_card.dual_sided_card?
    @listings = @mtg_card.listings.available
    if not (@mtg_card.active or current_admin_user)
      redirect_to (:root)
      return false
    end

    respond_to do |format|
      format.html # show.html.erb
    end

  end

  def search
    # SEARCH CARDS                
    query = SmartTuple.new(" AND ")
    query << ["mtg_cards.active LIKE ?", true]
    query << ["mtg_sets.active LIKE ?", true] 
    query << ["mtg_cards.name LIKE ?", "%#{params[:name]}%"] if params[:name].present?
    query << ["mtg_sets.code LIKE ?", "#{params[:set]}"] if params[:set].present?
    query << ["mana_color LIKE ?", "%#{params[:white]}%"] if params[:white].present?
    query << ["mana_color LIKE ?", "%#{params[:black]}%"] if params[:black].present?    
    query << ["mana_color LIKE ?", "%#{params[:blue]}%"] if params[:blue].present?
    query << ["mana_color LIKE ?", "%#{params[:red]}%"] if params[:red].present?
    query << ["mana_color LIKE ?", "%#{params[:green]}%"] if params[:green].present?
    query << ["rarity LIKE ?", "%#{params[:rarity]}%"] if params[:rarity].present?
    query << ["card_type LIKE ?", "%#{params[:type]}%"] if params[:type].present?
    query << ["card_subtype LIKE ?", "%#{params[:subtype]}%"] if params[:subtype].present?
    query << ["artist LIKE ?", "%#{params[:artist]}%"] if params[:artist].present?
    query << SmartTuple.new(" AND ").add_each(params[:abilities]) {|v| ["description LIKE ?", "%#{v}%"]} if params[:abilities].present? 
    @mtg_cards = Mtg::Card.joins(:set).where(query.compile).order("name").page(params[:page]).per(25)
    if @mtg_cards.length == 1
      redirect_to mtg_card_path(@mtg_cards[0])
    end
  end
  
  def autocomplete_name
    @mtg_cards = Mtg::Card.joins(:set).where("mtg_cards.name LIKE ? AND mtg_cards.active LIKE ? AND mtg_sets.active LIKE ?", "%#{params[:term]}%", true, true).limit(25) #grab 25.  we will display only 15, but will filter out repeats later.
    respond_to do |format|
      format.json {}  #loads view autocomplete_name.json.erb which returns json hash array of information
    end
  end
  
end
