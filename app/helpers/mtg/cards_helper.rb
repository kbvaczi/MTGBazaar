# encoding: UTF-8
# make this module available to be included in other areas by using "include Mtg::CardsHelper"
module Mtg::CardsHelper

  def self.camelcase_to_spaced(word)
    word.gsub(/([A-Z])/, " \\1").strip
  end
  
  # display only first 30 characters of a name"
  def display_name(name = "")
    name.truncate(30, :omission => "...")
  end
  
  # display only first 30 characters of a name"
  def display_type(type, subtype)
    if subtype.length > 1
      "#{type} - #{subtype}"
    else
      "#{type}"
    end
  end  
  
  # Converts mana string to a series of corresponding image links to be displayed
  def display_symbols(string)
    string = "{0}" if string.empty? # show a 0 mana symbol if mana string is empty      
    string.gsub(/[{]([_a-zA-Z0-9]+)[}]/) do |letter| #find the pattern "{xy}" where xy are any letters or numbers
        letter = letter.gsub(/[{](.+)[}]/, '\1').downcase #strip the {} and lowercase the letters
        if letter == "t" #if the letters are t, create tap image
          image_tag('https://s3.amazonaws.com/mtgbazaar/images/mtg/various_symbols/tap.jpg', :class => "mtg_symbol")         
        else #else the symbol must be a mana symbol, create corresponding mana symbol 
          #image_tag("https://mtgbazaar.s3.amazonaws.com/images/mtg/mana_symbols/mana_#{letter}.jpg", :class => "mtg_symbol")
          content_tag(:span, "", :class => "mana_symbol_sprite mana_#{letter}", :title => "Mana Symbol")
        end
    end.html_safe
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
  
  # defines an array containing all conditions for select boxes
  def condition_list
    Array.new([["Near Mint", "1"], ["Slightly Played", "2"], ["Moderately Played", "3"], ["Heavily Played", "4"]])
  end
  
  def display_condition(string)
     case string
       when /1/ 
         return "NM"
       when /2/ 
         return "SP"
       when /3/ 
         return "MP"
       when /4/ 
         return "HP"         
       else return "Unknown"
     end
   end
   
  def thumbnail_image_path(card)
    return card.image_path.gsub(".jpg", "_thumb.jpg")
  end
  
  def abilities_list
    Rails.cache.fetch 'abilities_list' do
      Mtg::Cards::Ability.pluck(:name).sort rescue []
    end
  end
  
  # Defines an array containing all the card types for select boxes
  def card_type_list
    Rails.cache.fetch 'card_type_list' do
      Mtg::Card.pluck(:card_type).each {|t| t.gsub!(/[ ][\/][\/][ ](.*)/,"")}.uniq.sort rescue []
    end
  end
  
  # Defines an array containing all the card types for select boxes
  def card_subtype_list
    Rails.cache.fetch 'card_subtype_list' do
      Mtg::Card.pluck(:card_subtype).uniq.sort rescue []
    end
  end  

  # Defines an array containing all the card types for select boxes
  def ability_list
    Rails.cache.fetch 'card_ability_list' do
      Array.new(['Absorb',	'Affinity',	'Amplify',	'Annihilator',	'Attach',	'Aura swap',	'Banding',	'Bands with other',	'Battle cry',	'Bloodthirst',	'Bury',	'Bushido',	'Buyback',	'Cascade',	'Champion',	'Changeling',	'Channel',	'Chroma',	'Clash',	'Conspire',	'Convoke',	'Counter',	'Cumulative upkeep',	'Cycling',	'Deathtouch',	'Defender',	'Delve',	'Devour',	'Domain',	'Double strike',	'Dredge',	'Echo',	'Enchant',	'Entwine',	'Epic',	'Equip',	'Evoke',	'Exalted',	'Exile',	'Fading',	'Fateful hour',	'Fateseal',	'Fear',	'Fight',	'First strike',	'Flanking',	'Flash',	'Flashback',
                      'Flip',	'Flying',	'Forecast',	'Fortify',	'Frenzy',	'Graft',	'Grandeur',	'Gravestorm',	'Haste',	'Haunt',	'Hellbent',	'Hexproof',	'Hideaway',	'Horsemanship',	'Imprint',	'Infect',	'Intimidate',	'Join forces',	'Kicker',	'Kinship',	'Landfall',	'Landhome',	'Landwalk',	'Level up',	'Lifelink',	'Living weapon',	'Madness',	'Metalcraft',	'Modular',	'Morbid',	'Morph',	'Multikicker',	'Ninjutsu',	'Offering',	'Persist',	'Phasing',	'Poisonous',	'Proliferate',	'Protection',	'Provoke',	'Prowl',	'Radiance',	'Rampage',	'Reach',	'Rebound',	'Recover',	'Regenerate',	'Reinforce',
                      'Replicate',	'Retrace',	'Ripple',	'Sacrifice',	'Scry',	'Shadow',	'Shroud',	'Soulshift',	'Splice',	'Split second',	'Storm',	'Substance',	'Sunburst',	'Suspend',	'Sweep',	'Tap/Untap',	'Threshold',	'Totem armor',	'Trample',	'Transfigure',	'Transform',	'Transmute',	'Typecycling',	'Undying',	'Unearth',	'Vanishing',	'Vigilance',	'Wither']).sort!
    end
  end  


  # lists all available rarities for select boxes
  def rarity_list
    Array.new([["Common","C"], ["Uncommon","U"], ["Rare","R"], ["Mythic","M"], ["Timeshifted","T"]])
  end
  
  # lists all available artists for select boxes
  def artist_list
    Rails.cache.fetch 'card_artist_list' do
      Mtg::Card.pluck(:artist).uniq.each do |a| 
        a.gsub!(/[\S\s]["].*["]/,"")
        a.gsub!(/[ ][\/][\/][ ](.*)/,"")
        a.gsub!(/[ ][&][ ](.*)/,"")        
        a.gsub!(/[ ]and[ ](.*)/,"")                
      end.uniq.sort
    end
  end
  
  def display_language(language_abbreviation)
    language_list.each { |l| return l[0] if l[1] == language_abbreviation }
  end
  
  # lists all available languages for select boxes
  def language_list
    return [["English","EN"], ["Russian","RU"], ["French","FR"], ["Japanese","JN"], ["Chinese","CN"], ["Korean","KO"], ["German","GN"], ["Portuguese", "PG"], ["Spanish", "SP"], ["Italian", "IT"]]
  end
  
  def active_set_list(options = {})
    begin
      if options[:sort] == "name"
        sort = "name DESC"       
      else
        sort = "name ASC" 
      end
      sets = Mtg::Set.where(:active => true).order("#{sort}").to_a
      return sets.collect(&:name).zip(sets.collect(&:code))
    rescue
      []
    end
  end

  # displays set symbol for a given set code
  def display_set_symbol(set, options = {})
    content_tag(:span, "", :class => "set_symbol_sprite set_symbol_#{set.code}", :title => "#{set.name}")
  end
  
  # displays set symbol for a given set code
  def display_set_symbol_by_id(set_name, set_code, options = {})
    content_tag(:span, "", :class => "set_symbol_sprite set_symbol_#{set_code}", :title => "#{set_name}")
  end
  
  # displays set symbol for a given set code
  def display_flag_symbol(language_code, options = {})
    language = display_language(language_code)
    height   = options[:height] || "20px"
    image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/flags/#{language.downcase}.png", :title => "#{language}", :style => "display:inline-block;height:#{height};width:#{height};vertical-align:text-top;")         
  end  
  
  def listing_option_foil_icon
    #image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/foil.png", :title => "Foil", :class => "mtg_option_symbol")         
	  content_tag :span, nil, :class => "option_symbol_sprite_small option_symbol_foil", :title => "Foil"  
  end

  def listing_option_altart_icon
    #image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/alt.png", :title => "Alternate art",:class => "mtg_option_symbol")         
	  content_tag :span, nil, :class => "option_symbol_sprite_small option_symbol_alt", :title => "Altered Art"      
  end

  def listing_option_misprint_icon
    #image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/miscut.png", :title => "Misprint",:class => "mtg_option_symbol")         
	  content_tag :span, nil, :class => "option_symbol_sprite_small option_symbol_miscut", :title => "Misprinted"      
  end

  def listing_option_scan_icon(listing)
    #image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/scan.png", :title => "Click to view scan", :class => "overlay_trigger mtg_option_symbol", :style => "cursor:pointer;", :rel => "#scan_overlay_#{listing.id}")
	  content_tag :span, nil, :class => "option_symbol_sprite_small option_symbol_scan overlay_trigger", :title => "Click to View Scan", :style => "cursor:pointer;", :rel => "#scan_overlay_#{listing.id}"
  end
  
  def listing_option_scan_overlay(listing)      
    content_tag(:div, image_tag(listing.scan.url, :title => "Card Scan", :style => "max-width:500px;max-height:500px;"), :class => "overlay_window", :id => "scan_overlay_#{listing.id}")    
  end

  def listing_option_signed_icon
    #image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/signed.png", :title => "Signed by artist",:class => "mtg_option_symbol")         
	  content_tag :span, nil, :class => "option_symbol_sprite_small option_symbol_signed", :title => "Signed by Artist"          
  end  
  
  def listing_option_description_icon(listing)
    #image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/description.png", :title => "#{listing.description}", :class => "tooltip_trigger mtg_option_symbol")         
	  content_tag :span, nil, :class => "option_symbol_sprite_small option_symbol_description tooltip_trigger", :title => "#{listing.description}"   
  end
  
  def menu_icon
    #image_tag("https://s3.amazonaws.com/mtgbazaar/images/mtg/options/options.png", :style => "display:inline-block;height:20px;vertical-align:bottom;")         
	  content_tag :span, nil, :class => "option_symbol_sprite_small option_symbol_options", :title => "Edit This Listing"       
  end
  
end
