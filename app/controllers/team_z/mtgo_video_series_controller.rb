class TeamZ::MtgoVideoSeriesController < ApplicationController

  before_filter :verify_team_z_member,   :except  => [:show]
  before_filter :verify_ownership,       :except  => [:show, :index, :new, :create, :publish, :edit_to_publish]
  before_filter :verify_content_manager, :only    => [:publish, :edit_to_publish]
  
  def index
    set_back_path
    if params[:role] == 'content_manager' && current_user.team_z_profile.can_manage_content
      respond_to do |format|
        format.html { render            :template => 'team_z/mtgo_video_series/index_as_manager' }
        format.js   { default_js_render :template => 'team_z/mtgo_video_series/index_as_manager' }
      end
    else
      respond_to do |format|
        format.html { }
        format.js   { default_js_render :template => 'team_z/mtgo_videos_series/index' }
      end
    end
  end
  
  def show
    set_back_path
    if current_video_series.present?
      respond_to do |format|
        format.html { }
        format.js   { default_js_render :template => 'team_z/mtgo_video_series/show' }
      end    
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def new
    @video_series ||= TeamZ::MtgoVideoSeries.new(params[:team_z_mtgo_video_series])
    3.times { @video_series.videos.build }
    respond_to do |format|
      format.html { }
    end
  end
  
  def create
    @video_series ||= TeamZ::MtgoVideoSeries.new(params[:team_z_mtgo_video_series])
    @video_series.assign_attributes(:active => false, :team_z_profile_id => current_user.team_z_profile_id, :active_at => nil)
    if @video_series.save
      redirect_to back_path, :notice => 'Your video series was created...'
    else
      Rails.logger.debug @video_series.attributes
      Rails.logger.debug @video_series.errors.full_messages
      flash[:error] = 'There was a problem with your request...'
      render 'new'
    end
  end
  
  def edit
    current_video_series
    respond_to do |format|
      format.html
    end
  end
  
  def update
    current_video_series.assign_attributes(params[:team_z_mtgo_video_series].merge(:active => false, :team_z_profile_id => (current_video_series.team_z_profile_id || current_user.team_z_profile_id), :active_at => nil))
    if @video_series.save
      redirect_to back_path, :notice => 'Your video series was successfully updated'
    else
      Rails.logger.debug @video_series.attributes
      Rails.logger.debug @video_series.errors.full_messages
      flash[:error] = 'There was a problem with your request...'
      render 'new'
    end    
  end
  
  def edit_to_publish
    if current_video_series.present?
      respond_to do |format|
        format.js
      end    
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end
  
  def publish
    current_video_series.assign_attributes(params[:team_z_mtgo_video_series].merge(:team_z_profile_id => current_video_series.team_z_profile_id, :active => true))
    Rails.cache.clear(TeamZ::MtgoVideoSeries.cache_key) if current_video_series.active_at < Time.zone.now
    if current_video_series.save
      redirect_to back_path, :notice => 'The video series was published'
    else
      flash[:error] = 'There was a problem with your request...'
      redirect_to back_path
    end
  end
  
  def unpublish
    current_video_series.assign_attributes(:active => false, :active_at => nil)    
    if current_video_series.save
      redirect_to back_path, :notice => 'The article was un-published'
    else
      flash[:error] = 'There was a problem with your request...'
      redirect_to back_path
    end
  end
  
  def destroy
    if current_video_series.active.nil? or current_user.team_z_profile.can_manage_content
      current_video_series.destroy
      redirect_to back_path, :notice => 'The video series was deleted...'
    else
      flash[:error] = 'You cannot delete active video series...'
      redirect_to back_path
    end
  end
  
  private 
  
  def verify_team_z_member
    unless current_user.team_z_profile_id.present?
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to back_path      
    end
  end
  
  def verify_ownership
    unless current_user.present? and (current_user.team_z_profile_id == current_video_series.team_z_profile_id or current_user.team_z_profile.can_manage_content)
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to back_path
    end
  end
  
  def verify_content_manager
    unless current_user.present? and current_user.team_z_profile.can_manage_content
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to back_path
    end
  end
  
  def current_video_series
    if user_signed_in? and current_user.team_z_profile.present? 
      @video_series ||= TeamZ::MtgoVideoSeries.includes(:profile).find(params[:id])
    else
      @video_series ||= TeamZ::MtgoVideoSeries.includes(:profile).viewable.where(:id => params[:id]).first
    end
  end

  
end