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
  
  def us_states
      [
        ['Alabama', 'AL'],
        ['Alaska', 'AK'],
        ['Arizona', 'AZ'],
        ['Arkansas', 'AR'],
        ['California', 'CA'],
        ['Colorado', 'CO'],
        ['Connecticut', 'CT'],
        ['Delaware', 'DE'],
        ['District of Columbia', 'DC'],
        ['Florida', 'FL'],
        ['Georgia', 'GA'],
        ['Hawaii', 'HI'],
        ['Idaho', 'ID'],
        ['Illinois', 'IL'],
        ['Indiana', 'IN'],
        ['Iowa', 'IA'],
        ['Kansas', 'KS'],
        ['Kentucky', 'KY'],
        ['Louisiana', 'LA'],
        ['Maine', 'ME'],
        ['Maryland', 'MD'],
        ['Massachusetts', 'MA'],
        ['Michigan', 'MI'],
        ['Minnesota', 'MN'],
        ['Mississippi', 'MS'],
        ['Missouri', 'MO'],
        ['Montana', 'MT'],
        ['Nebraska', 'NE'],
        ['Nevada', 'NV'],
        ['New Hampshire', 'NH'],
        ['New Jersey', 'NJ'],
        ['New Mexico', 'NM'],
        ['New York', 'NY'],
        ['North Carolina', 'NC'],
        ['North Dakota', 'ND'],
        ['Ohio', 'OH'],
        ['Oklahoma', 'OK'],
        ['Oregon', 'OR'],
        ['Pennsylvania', 'PA'],
        ['Puerto Rico', 'PR'],
        ['Rhode Island', 'RI'],
        ['South Carolina', 'SC'],
        ['South Dakota', 'SD'],
        ['Tennessee', 'TN'],
        ['Texas', 'TX'],
        ['Utah', 'UT'],
        ['Vermont', 'VT'],
        ['Virginia', 'VA'],
        ['Washington', 'WA'],
        ['West Virginia', 'WV'],
        ['Wisconsin', 'WI'],
        ['Wyoming', 'WY']
      ]
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
