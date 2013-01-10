class TeamZ::MtgoVideoSeriesController < ApplicationController

  def show
    @video_series = TeamZ::MtgoVideoSeries.includes(:profile).find(params[:id])
    respond_to do |format|
      format.html { }
      format.js   { default_js_render :template => 'team_z/mtgo_video_series/show' }
    end    
  end
  
end