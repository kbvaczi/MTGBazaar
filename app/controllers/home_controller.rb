class HomeController < ApplicationController

  def index
    set_back_path
    if admin_user_signed_in?      
      render :layout => 'homepage'
    else
      render :template => '/home/index_old'
    end  
  end
  
  def sitemap
    redirect_to "http://mtgbazaar-public.s3.amazonaws.com/sitemaps/sitemap_index.xml.gz"
  end
  

  def blitz
    # this authorizes blitz to load test on our website.    
    render :text => '42'
  end
  
  def robots
    # serves robots.txt based on environment
    robots = File.read(Rails.root + "public/robots.#{Rails.env}.txt")
    render :text => robots, :layout => false, :content_type => "text/plain"
  end
  
  def test

  end

end
