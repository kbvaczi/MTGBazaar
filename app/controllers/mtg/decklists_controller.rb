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
      format.js
    end
  end
  
  def create
    @decklist ||= Mtg::Decklist.new(params[:mtg_decklist])
    if @decklist.save
      redirect_to back_path, :notice => 'Your deck was created...'
    else
      flash[:error] = 'There was a problem with your request...'
      render 'new'
    end
  end
  
  def edit
    current_decklist
    respond_to do |format|
      format.html
    end
  end
  
  def update
    current_decklist.assign_attributes(params[:mtg_decklist])
    if current_decklist.save
      redirect_to back_path, :notice => 'Your deck was successfully updated'
    else
      flash[:error] = 'There was a problem with your request...'
      render 'edit'
    end    
  end

  def destroy
    current_decklist.destroy
    redirect_to back_path, :notice => 'The deck was deleted...'
  end
  
  
  private 
  
  def verify_team_z_member
    unless current_user.team_z_profile_id.present?
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to back_path      
    end
  end
  
  def current_decklist
    @decklist ||= Mtg::Decklist.find(params[:id])    
  end

  
end