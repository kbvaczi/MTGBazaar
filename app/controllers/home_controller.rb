class HomeController < ApplicationController
  
  def index
    @news_feeds = NewsFeed.order("created_at DESC").limit(1)
  end
  
end
