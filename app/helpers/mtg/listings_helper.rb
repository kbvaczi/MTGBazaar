module Mtg::ListingsHelper
  
  def listing_option_foil_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/foil.png", :title => "Foil", :style => "float:left;height:20px;vertical-align:bottom;")         
  end

  def listing_option_altart_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/alt.png", :title => "Alternate art", :style => "float:left;height:20px;vertical-align:bottom;")         
  end

  def listing_option_misprint_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/miscut.png", :title => "Misprint", :style => "float:left;height:20px;vertical-align:bottom;")         
  end

  def listing_option_scan_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/scan.png", :title => "Click to view scan", :style => "float:left;height:20px;vertical-align:bottom;")         
  end      

  def listing_option_signed_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/signed.png", :title => "Signed by artist", :style => "float:left;height:20px;vertical-align:bottom;")         
  end  
  
  def listing_option_description_icon(listing)
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/description.png", :title => "Description: #{listing.description}", :style => "float:left;height:20px;vertical-align:bottom;")         
  end  
    
end
