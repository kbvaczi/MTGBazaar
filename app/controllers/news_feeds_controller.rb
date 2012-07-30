class NewsFeedsController < ApplicationController
  
  def index
    @news_feeds = NewsFeed.order("created_at DESC").page(params[:page]).per(5)
  end
  
end