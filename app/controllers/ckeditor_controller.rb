class CkeditorController < ApplicationController
  
  def get_available_sets_from_card_name
    set_names = Mtg::Set.joins(:cards).where('mtg_cards.name LIKE ?', params[:card_name]).order("mtg_sets.release_date DESC").values_of :name, :code
    render :json => set_names
  end
  
  def get_image_path_from_card_and_set_name
    card = Mtg::Card.joins(:set).select(['mtg_cards.id', :image_path, 'mtg_cards.name']).where('mtg_cards.name LIKE ?', params[:card_name]).where("mtg_sets.code LIKE ?", params[:set_code]).limit(1).first
    info = [card.image_path, mtg_card_path(card), card.name]
    render :text => info
  end
  
  def get_available_formats_from_decklist_name
    
  end
  
  def get_decklist_info_from_name_and_format
    
  end
  
end