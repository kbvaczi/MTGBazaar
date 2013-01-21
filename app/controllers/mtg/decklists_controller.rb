class Mtg::DecklistsController < ApplicationController

  before_filter :verify_team_z_member, :except  => [:show, :index]
  
  def index
  end
  
  def show
  end
  
  def new
    @decklist ||= Mtg::Decklist.new(params[:mtg_decklist])
    respond_to do |format|
      format.html
      format.js do
        if params[:position] == 'overlay'
          overlay_js_render :template => 'mtg/decklists/new'
        else
          default_js_render :template => 'mtg/decklists/new'
        end
      end
    end
  end
    
  def create
    @decklist ||= Mtg::Decklist.new(params[:mtg_decklist])
    if @decklist.save
      respond_to do |format|
        format.html { redirect_to back_path, :notice => 'Your deck was created...' }
        format.js do 
          render :js => %{myCustomAlertBox("Decklist: #{@decklist.name} was created!");
                          $('.overlay_window').overlay().close();} 
        end
      end
    else
      flash[:error] = @decklist.get_relevant_error_message
      respond_to do |format|
        format.html { render 'new' }
        format.js   { render :js => %{myCustomAlertBox("#{@decklist.get_relevant_error_message}");} }
      end
    end
  end
  
  def edit
    current_decklist.decklist_text_main      = params[:mtg_checklist][:decklist_text_main]      rescue current_decklist.export_format(:section => 'Main Deck')
    current_decklist.decklist_text_sideboard = params[:mtg_checklist][:decklist_text_sideboard] rescue current_decklist.export_format(:section => 'Sideboard')
    current_decklist   
    respond_to do |format|
      format.html
      format.js do
        if params[:position] == 'overlay'
          overlay_js_render :template => 'mtg/decklists/edit'
        else
          default_js_render :template => 'mtg/decklists/edit'
        end
      end
    end
  end
  
  def update
    if current_decklist.update_attributes(params[:mtg_decklist])
      respond_to do |format|
        format.html { redirect_to back_path, :notice => 'Your deck was updated...' }
        format.js do 
          render :js => %{myCustomAlertBox("Decklist: #{current_decklist.name} was Updated!");
                          $('.overlay_window').overlay().close();} 
        end
      end
    else
      Rails.logger.info (request.format)                      
      respond_to do |format|
        format.html do 
          flash[:error] = @decklist.get_relevant_error_message
          render 'edit'
        end
        format.js do 
          Rails.logger.info(current_decklist.get_relevant_error_message)
          render :js => %{myCustomAlertBox("#{current_decklist.get_relevant_error_message}");} 
        end
      end
    end
  end

  def destroy
    current_decklist.destroy
    redirect_to back_path, :notice => 'The deck was deleted...'
  end
  
  private 
  
  def verify_team_z_member
    unless user_signed_in? and current_user.team_z_profile_id.present?
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to back_path      
    end
  end
  
  def current_decklist
    @decklist ||= Mtg::Decklist.find(params[:id])    
  end

  
end