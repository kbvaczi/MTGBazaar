class TeamZ::ArticlesController < ApplicationController

  def show
    @article        = TeamZ::Article.includes(:profile).find(params[:id])
    respond_to do |format|
      format.html { }
      format.js   { default_js_render :template => 'team_z/articles/show' }
    end    
  end
  
end