ActiveAdmin.register Admin::SliderCenterSlide do
  
  menu :label => "Center Slider", :parent => "Site Configuration"
  
  # ----- CUSTOMIZE EDIT FORM ----- #
    
  form :partial => "admin/slider_center_slides/form"

  # ------ INDEX PAGE CUSTOMIZATIONS ------ #
  
  # ------ Controller ----- #
  
  collection_action :get_news_feed_link, :method => :get do
    news_feed = NewsFeed.find(params[:id])
    if news_feed.present?
      data    = {:link => news_feed_path(news_feed), :title => news_feed.title, :description => news_feed.description}
    else
      data    = ''
    end
    Rails.logger.debug data.to_json
    render :json => data
  end
  
end