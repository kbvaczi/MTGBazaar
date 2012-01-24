class MtgCardsController < ApplicationController
  # GET /mtg_cards
  # GET /mtg_cards.json
  def index

    if params[:set]
      @mtg_cards = MtgSet.order("name").where(:code => params[:set]).first.cards
      @sets = []
    else
      @sets = MtgSet.order("name").all
      @mtg_cards = []
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mtg_cards }
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

end
