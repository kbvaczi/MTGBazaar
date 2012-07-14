class HomeController < ApplicationController
  
  def index
    @news_feeds = NewsFeed.order("priority ASC, created_at DESC").limit(5)
  end
  
end
