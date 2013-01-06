class TeamZ::ArticlesController < ApplicationController

  def show
    @article        = TeamZ::Article.includes(:profile).find(params[:id])
    @other_articles = TeamZ::Article.includes(:profile).viewable.where(:team_z_profile_id => @article.team_z_profile_id).where('team_z_articles.id <> ?', @article.id).order('active_at DESC').limit(3)
  end
  
end