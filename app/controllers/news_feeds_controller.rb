class NewsFeedsController < ApplicationController
  
  def index
    @news_feeds = NewsFeed.viewable
                          .order("created_at DESC")
                          .page(params[:page])
                          .per(5)
  end
  
  def show
    @news_feed  = NewsFeed.viewable
                          .find(params[:id])
  end
  
end