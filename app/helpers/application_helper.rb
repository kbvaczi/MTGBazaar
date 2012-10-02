module ApplicationHelper

  def title(page_title)
    provide :title, " | #{page_title.parameterize}"
  end
  
  def capitalize_first_word(word)
    word.split(' ').map {|w| w.capitalize }.join(' ')
  end
  
  def display_time(time, options = {})
    if options[:day] == false
      time.strftime("%b %Y")
    else 
      time.strftime("%b %d, %Y")
    end
  end
  
  def us_states
    ["AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA",
    "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH",
    "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY"]
  end
  
  def back_link(options)
    content_tag :div, link_to("back", options[:path] || request.referer, :class => "bx-prev", :style => "top:6px;") + content_tag(:div, options[:message] || "Back", :class => "t-s", :style => "position:absolute;top:10px;left:28px;")
  end

  def sort_table_header(title, value, options = {:remote => false})
    if params[:sort] && params[:sort].to_s == "#{value}_asc"
      link_to title, params.merge(:sort => "#{value}_desc"), :remote => options[:remote], :style => "color:#555;"     
    else
      link_to title, params.merge(:sort => "#{value}_asc"), :remote => options[:remote], :style => "color:#555;"     
    end
     #params[:sort], params[:sort] == '#{value}_asc' ? params.merge(:sort => "#{value}_desc") : params.merge(:sort => "#{value}_asc") rescue params.merge(:sort => "#{value}_asc")
  end
    
  def sort_direction
    case params[:sort]
      when /_asc/
        "ASC"
      when /_desc/
        "DESC"
    end
  end
    
end

def menu_icon
  image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/options.png", :style => "display:inline-block;height:20px;vertical-align:bottom;")         
end
