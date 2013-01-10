class TeamZ::ProfilesController < ApplicationController

  def show
    @profile = TeamZ::Profile.includes(:articles).find(params[:id])
    respond_to do |format|
      format.html { }
      format.js   { default_js_render :template => 'team_z/profiles/show' }
    end
  end
  
end