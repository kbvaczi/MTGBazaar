class HomeController < ApplicationController

  caches_action :sitemap
  
  def index
    set_back_path
    if user_signed_in?
      @news_feeds = NewsFeed.available_to_view.order("created_at DESC").limit(1) #.page(params[:page]).per(5)
    else
      @news_feeds = NewsFeed.where(:id => 1)
    end
  end
  
  def sitemap
    redirect_to "http://mtgbazaar-public.s3.amazonaws.com/sitemaps/sitemap_index.xml.gz"
  end
  
  def test

  end

end
