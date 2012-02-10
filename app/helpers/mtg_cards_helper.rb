module MtgCardsHelper
  # make this module available to be included in other areas by using "include MtgCardsHelper"
  def self.camelcase_to_spaced(word)
    word.gsub(/([A-Z])/, " \\1").strip
  end
  
  # display only first 30 characters of a name"
  def display_name(name)
    name.truncate(35, :omission => "...")
  end
  
  # Converts mana string to a series of corresponding image links to be displayed
  def display_symbols(string)
    if string.empty?
      return "None"
    else
      string.gsub(/[{]([a-zA-Z0-9]+)[}]/) do |letter| #find the pattern "{xy}" where xy are any letters or numbers
          letter = letter.gsub(/[{](.+)[}]/, '\1').downcase #strip the {} and lowercase the letters
          if letter == "t" #if the letters are t, create tap image
            image_tag('/assets/mtg/various_symbols/tap.jpg', :class => "mtg_symbol") if letter == "t"          
          else #else the symbol must be a mana symbol, create corresponding mana symbol 
            image_tag("/assets/mtg/mana_symbols/mana_#{letter}.jpg", :class => "mtg_symbol") if letter != "t"
          end
      end.html_safe
      #return_string = string
      #return_string = return_string.gsub(/[{][T][}]/, image_tag("/assets/mtg/various_symbols/tap.jpg")) # display tap symbol, overwrite string
      #return_string = return_string.gsub(/[{]([a-zA-Z0-9]+)[}]/, '<img alt=\'mana_\1\' src=\'/assets/mtg/mana_symbols/mana_\1.jpg\' class=\'mtg_symbol\'>') # display everything else
      #return return_string.html_safe # tells rails it's OK to render HTML tags
    end
  end
  
  def display_color(string)
    case string
      when /[a-zA-Z ]+[(]O[)] \/\/ [a-zA-Z ]+[(]O[)]/ # contains "XYZ (O) // XYZ (O)", XYZ is any letter combination/length
        return "Split / Gold"
      when /[(]O[)]/ # contains "(O)"
        return "Multicolor"
      when /[A]+/  # contains "A"
        return "Artifact"        
      when /[(]H[)]/ # contains "(H)"
        return "Hybrid"
      when /\/\// # contains "//"
        return "Split"
      when /L/ #contains "L"
        return "Land"        
      when /\AU\z/ #equals "U"
        return "Blue"
      when /\AB\z/ #equals "B"
        return "Black"
      when /\AW\z/ #equals "W"
        return "White"
      when /\AR\z/ #equals "R"
        return "Red"                        
      when /\AG\z/ #equals "G"
        return "Green"       
      when /\AS\z/ #equals "S"
        return "Scheme"        
      when /\AC\z/ #equals "C"
        return "Colorless"     
      when /\AP\z/ #equals "P"
        return "Plane"
      when /[a-zA-Z]{2}+/ #longer than 1 letter
        return "Multicolor"
      else return "Unknown"                   
    end
  end
  
  def display_rarity(string)
    case string
      when /C/ #contains "C" 
        return "Common"
      when /U/ #contains "U" 
        return "Uncommon"
      when /R/ #contains "R" 
        return "Rare"
      when /M/ #contains "M" 
        return "Mythic"
      when /T/ #contains "T" 
        return "Timeshifted"
      else return "Unknown"
    end
  end  
end
