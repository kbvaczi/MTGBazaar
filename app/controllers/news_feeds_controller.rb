class NewsFeedsController < ApplicationController
  
  def index
    @news_feeds = NewsFeed.available_to_view
                          .order("created_at DESC")
                          .page(params[:page])
                          .per(5)
  end
  
  def show
    @news_feed  = NewsFeed.available_to_view
                          .find(params[:id])
  end
  
end