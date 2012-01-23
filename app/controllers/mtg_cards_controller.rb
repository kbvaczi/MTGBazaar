class MtgCardsController < ApplicationController
  # GET /mtg_cards
  # GET /mtg_cards.json
  def index
    @mtg_cards = MtgCard.all

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
