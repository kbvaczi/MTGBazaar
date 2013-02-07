class Mtg::DecklistsController < ApplicationController

  before_filter :verify_team_z_member, :except  => [:show, :index]
  
  def index
    set_back_path
    respond_to do |format|
      format.html
      format.js { default_js_render :template => 'mtg/decklists/index' }
    end
  end
  
  def show
    respond_to do |format|
      format.html do
        render :partial => 'mtg/decklists/show', :locals => {:decklist => current_decklist}
      end
      format.js { overlay_js_render :partial => 'mtg/decklists/show', :locals => {:decklist => current_decklist} }
      format.text do
        render :text => "#{current_decklist.export_format(:section => 'main deck')}\r\n#{current_decklist.export_format(:section => 'sideboard')}"
      end
    end
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
    @decklist ||= Mtg::Decklist.new(params[:mtg_decklist].merge(:author_id => current_user.id))
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
    current_decklist.decklist_text_main      = params[:mtg_checklist][:decklist_text_main]      rescue current_decklist.export_format(:section => 'Main Deck')
    current_decklist.decklist_text_sideboard = params[:mtg_checklist][:decklist_text_sideboard] rescue current_decklist.export_format(:section => 'Sideboard')    
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
  
  def autocomplete_name
    this_users_decklists = user_signed_in? ? Mtg::Decklist.where('mtg_decklists.name LIKE ?', "#{params[:term]}%").where(:author_id => current_user.id).order('created_at DESC').limit(5) : []
    @decklists = (this_users_decklists + Mtg::Decklist.where('mtg_decklists.name LIKE ?', "#{params[:term]}%").order('created_at DESC').limit(10)).to_a.uniq
    respond_to do |format|
      format.json {}
    end
  end
  
  def sales_frame
    card = Mtg::Card.includes(:statistics).where(:id => params[:id]).first
    if card.present?
      render :partial => 'sales_frame', :locals => {:mtg_card => card}
    end    
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