module ApplicationHelper

  def captcha_verified?
    return true if session[:captcha]
    return false
  end
  
  def title(page_title)
    provide :title, " | #{page_title}"
  end
  
  def capitalize_first_word(word)
    word.split(' ').map {|w| w.capitalize }.join(' ')
  end
  
  def back_path
    return session[:return_to]
  end
  
  def display_time(time)
    time.strftime("%d-%b %Y") 
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
  image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/options.png", :style => "float:left;height:20px;vertical-align:bottom;")         
end
