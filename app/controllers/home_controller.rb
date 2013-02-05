class HomeController < ApplicationController

  def index
    set_back_path
  end
  
  def sitemap
    redirect_to "http://mtgbazaar-public.s3.amazonaws.com/sitemaps/sitemap_index.xml.gz"
  end
  
  # this authorizes blitz to load test on our website.
  def blitz
    render :text => '42'
  end

end
