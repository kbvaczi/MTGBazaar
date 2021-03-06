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
  
  def ping
    # url for newrelic to hit which will do nothing
    render :text => 'OK'
  end
  
  def extend_session
    old_update_time = current_session.updated_at
    #update_current_session_to_prevent_expiration
    render :text => "#{old_update_time}, #{current_session.updated_at}"
  end
  
  def test

  end

end
