class HomeController < ApplicationController

  def index
    if user_signed_in?
      @news_feeds = NewsFeed.where("active LIKE ?", true)
                            .where("start_at < \'#{Time.now}\' OR start_at IS null")
                            .where("end_at > \'#{Time.now}\' OR end_at IS null")
                            .order("created_at DESC")
                            .limit(1)
                            #.page(params[:page])
                            #.per(5)
    else
    
      @news_feeds = NewsFeed.where(:id => 1)
  
    end
  end
  
end
