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
  
  def test
    sets      = Mtg::Set.pluck(:id)
    set_id    = sets[rand(0...sets.length)]
    card_type = card_type_list[rand(0...card_type_list.length)]
    cards     = Mtg::Card.includes(:listings => :seller).where(:set_id => set_id, :card_type => card_type)    
    Mtg::Cards::Statistics.delay.bulk_update_listing_information(cards.to_a.collect {|c| c.id})
  end

end
