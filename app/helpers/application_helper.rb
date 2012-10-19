module ApplicationHelper

  def title(page_title)
    provide :title, " | #{page_title.parameterize}"
  end
  
  def capitalize_first_word(word)
    word.split(' ').map {|w| w.capitalize }.join(' ')
  end
  
  def display_time(time, options = {})
    if options[:day] == false
      time.strftime("%m/%d/%y")
    else 
      time.strftime("%m/%d/%y")
    end
  end
  
  def us_states
    [ ['Alaska', 'AK'], ['Alabama', 'AL'], ['Arizona', 'AZ'], ['Arkansas', 'AR'], ['California', 'CA'], ['Colorado', 'CO'], ['Connecticut', 'CT'],
      ['Delaware', 'DE'], ['District of Columbia', 'DC'], ['Florida', 'FL'], ['Georgia', 'GA'], ['Hawaii', 'HI'], ['Idaho', 'ID'],
      ['Illinois', 'IL'], ['Indiana', 'IN'], ['Iowa', 'IA'], ['Kansas', 'KS'], ['Kentucky', 'KY'], ['Lousiana', 'LA'], ['Maine', 'ME'], ['Maryland', 'MD'], 
      ['Massachusetts', 'MA'], ['Michigan', 'MI'], ['Minnesota', 'MN'], ['Mississippi', 'MS'], ['Missouri', 'MO'], ['Montana', 'MT'], ['Nebraska', 'NE'],
      ['Nevada', 'NV'], ['New Hampshire', 'NH'], ['New Jersey', 'NJ'], ['New Mexico', 'NM'], ['New York', 'NY'], ['North Carolina', 'NC'], ['North Dakota', 'ND'],
      ['Ohio', 'OH'], ['Oklahoma', 'OK'], ['Oregon', 'OR'], ['Pennsylvania', 'PA'], ['Rhode Island', 'RI'], ['South Carolina', 'SC'],
      ['South Dakota', 'SD'], ['Tennessee', 'TN'], ['Texas', 'TX'], ['Utah', 'UT'], ['Virginia', 'VA'], ['Vermont', 'VT'], ['Washington', 'WA'],
      ['Wisconsin', 'WI'], ['West Virigina', 'WV'], ['Wyoming', 'WY'] ]
  end
  
  def back_link(options)
    content_tag :div, link_to("back", options[:path] || request.referer, :class => "bx-prev", :style => "top:6px;") + content_tag(:div, options[:message] || "Back", :class => "t-s", :style => "position:absolute;top:10px;left:28px;")
  end

  def table_sort_header(title, options = {:value => nil, :remote => false, :params => nil})
    sort = options[:value] || title.downcase
    if params[:sort] == title.downcase || options[:value]
      link_to title, params.merge(options[:params] || {}).merge(:sort => sort, :sort_order => (params[:sort_order] == "asc" ? "desc" : "asc")), :remote => options[:remote], :style => "color:#555;"     
    else
      link_to title, params.merge(options[:params] || {}).merge(:sort => sort, :sort_order => "asc"), :remote => options[:remote], :style => "color:#555;"     
    end
  end

  def menu_icon
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/options.png", :style => "display:inline-block;height:20px;vertical-align:bottom;")         
  end
    
end


