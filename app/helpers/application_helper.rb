module ApplicationHelper

  def title(page_title)
    provide :title, " | #{page_title.gsub(/[\[\]\^\$\.\|\?\*\+\\~`\!@#%\+={}'"<>;,]{1,}/, "").gsub("&", "and")}"
  end
  
  def capitalize_first_letters(word)
    word.downcase.split(' ').map {|w| w.capitalize }.join(' ')
  end
  
  def display_time(time, options = {})
    if options[:day] == false
      time.strftime("%m/%Y")
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
    content_tag :div, link_to("back", options[:path] || back_path) + content_tag(:div, options[:message] || "Back", :class => "t-s"), :id => "back_link"
  end

  def table_sort_header(title, options = {:value => nil, :remote => false, :params => nil})
    sort = options[:value] || title.downcase
    if params[:sort].present? && (params[:sort] == title.downcase || params[:sort] == options[:value])
      link_to title, params.merge(options[:params] || {}).merge(:page => 1, :sort => sort, :sort_order => (params[:sort_order] == "asc" ? "desc" : "asc")), :remote => options[:remote], :class => "table_header_sort_selected"     
    else
      link_to title, params.merge(options[:params] || {}).merge(:page => 1, :sort => sort, :sort_order => "asc"), :remote => options[:remote], :class => "table_header_sort"
    end
  end
  
  def pretty_print_hash(input_hash)
    output_string = ""
    if input_hash.class == Hash
      input_hash.each do |key, value|
        if value.class == Hash
          output_string << "<strong>:#{key} =></strong><div style=\"margin-left:3%\">"
          output_string << pretty_print_hash(value)
          output_string << "</div>"
        elsif value.class == Array
          output_string << "<div style=\"margin-left:3%\">"
          value.each {|v| output_string << ("[" + pretty_print_hash(v) + "]<br/>")}
          output_string << "</div>"
        else
          output_string << "<div><strong>:#{key} =></strong> #{value}</div>"
        end
      end
    else
      output_string << input_hash.inspect
    end
    output_string.html_safe
  end
    
end


