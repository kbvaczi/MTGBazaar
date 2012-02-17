class MtgCardsController < ApplicationController
  
  # GET /mtg_cards
  # GET /mtg_cards.json
  def index
    
      @title = "MTG Cards"
      # LIST ALL CARDS BY SET    
      if params[:set]
        @mtg_cards = MtgSet.order("name").where(:code => params[:set]).first.cards
       @sets = []
      else
        @sets = MtgSet.order("name").all
        @mtg_cards = []
      end
    
    respond_to do |format|
      format.html #index.html.erb
    end
    
  end

  # GET /mtg_cards/1
  # GET /mtg_cards/1.json
  def show
    @mtg_card = MtgCard.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mtg_card }
    end
  end

  def search
    
    # SEARCH CARDS                
    @mtg_cards = MtgCard.joins(:set).where("mtg_cards.name LIKE ? 
                                            AND code LIKE ?
                                            AND mana_color LIKE ? 
                                            AND mana_color LIKE ? 
                                            AND mana_color LIKE ? 
                                            AND mana_color LIKE ? 
                                            AND mana_color LIKE ?
                                            AND rarity LIKE ?
                                            AND card_type LIKE ?
                                            AND artist LIKE ?
                                            AND card_subtype LIKE?",
                                            "%#{params[:name]}%", 
                                            "%#{params[:set]}%", 
                                            "%#{params[:white]}%", 
                                            "%#{params[:blue]}%", 
                                            "%#{params[:black]}%", 
                                            "%#{params[:red]}%", 
                                            "%#{params[:green]}%",
                                            "%#{params[:rarity]}%",
                                            "%#{params[:type]}%",
                                            "%#{params[:artist]}%",
                                            "%#{params[:subtype]}%").order("name").page(params[:page]).per(25)
                                                       
  end
  
end
