class MtgCardsController < ApplicationController
  
  # GET /mtg_cards
  def index
    
    @title = "MTG Cards"
    # LIST ALL CARDS BY SET    
    if params[:set]
      @mtg_cards = MtgSet.order("name").where(:code => params[:set], :active => true).first.cards
     @sets = []
    else
      @sets = MtgSet.order("name").where(:active => true)
      @mtg_cards = []
    end
  
    respond_to do |format|
      format.html #index.html.erb
    end
    
  end

  # GET /mtg_cards/1
  def show
    @mtg_card = MtgCard.find(params[:id])
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
    if params[:set].empty? then set_search_value = "%%" else set_search_value = params[:set] end rescue set_search_value = "%%"
    @mtg_cards = MtgCard.joins(:set).where("mtg_cards.name LIKE ?  AND mtg_sets.code LIKE ? AND mana_color LIKE ?  AND mana_color LIKE ? AND mana_color LIKE ?  AND mana_color LIKE ? AND mana_color LIKE ?  AND rarity LIKE ?       AND card_type LIKE ?  AND artist LIKE ?       AND card_subtype LIKE?   AND mtg_cards.active LIKE ? AND mtg_sets.active LIKE ?",
                                           "%#{params[:name]}%", "#{set_search_value}",    "%#{params[:white]}%", "%#{params[:blue]}%", "%#{params[:black]}%", "%#{params[:red]}%",  "%#{params[:green]}%", "%#{params[:rarity]}%", "%#{params[:type]}%", "%#{params[:artist]}%", "%#{params[:subtype]}%",  true,                       true).order("name").page(params[:page]).per(25)
    if @mtg_cards.length == 1
      redirect_to mtg_card_path(@mtg_cards[0])
    end
  end
  
  def autocomplete_name
    @mtg_cards = MtgCard.joins(:set).where("mtg_cards.name LIKE ? AND mtg_cards.active LIKE ? AND mtg_sets.active LIKE ?", "%#{params[:term]}%", true, true).limit(20) #grab 20.  we will display only 10, but will filter out repeats later.
    respond_to do |format|
      format.json {}  #loads view autocomplete_name.json.erb which returns json hash array of information
    end
  end
  
end
