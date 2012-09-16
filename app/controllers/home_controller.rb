class HomeController < ApplicationController
  
  def index
   
    if user_signed_in?
      @news_feeds = NewsFeed.available_to_view.order("created_at DESC").limit(1) #.page(params[:page]).per(5)
    else
      @news_feeds = NewsFeed.where(:id => 1)
    end

    @address = build_address(:user => User.first, :clean => true)
  
  end
  
  # TESTING AREA  
  
  def build_address(params={})
    a = {
      :full_name   => params[:full_name].present? ? params[:full_name] : "#{params[:user].account.first_name} #{params[:user].account.last_name}" ,
      :first_name  => params[:user].account.first_name,
      :last_name   => params[:user].account.last_name,
      :address1    => params[:user].account.address1,
      :address2    => params[:user].account.address2,                  
      :city        => params[:user].account.city,
      :state       => params[:user].account.state,
      :zip_code    => params[:user].account.zipcode
    }
    params[:clean] == true ? Stamps.clean_address(:address => a) : a
  end
  
end
