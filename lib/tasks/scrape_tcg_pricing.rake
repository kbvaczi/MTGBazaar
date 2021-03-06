# encoding: UTF-8
#
# USAGE
# To Scrape one set:  rake scrape_tcg_pricing set_code=XXX (where XXX is a single set you want to scrape...)
# To Scrape all sets: rake scrape_tcg_pricing
task :scrape_card => :environment do 

  scrape_pricing_for_single_card(:statistics => Mtg::Card.find_by_name("Abrupt Decay").statistics, :tcg_set_name => "Return to Ravnica")
  
end

task :scrape_tcg_pricing => :environment do 
  
  include Mtg::CardsHelper
  
  puts "Starting to scrape pricing"
  
  #these are the sets that tcgplayer calles something else than we do
  different_set_name_list =   { "beta"            =>"beta edition", 
                                "alpha"           =>"alpha edition", 
                                "planechase 2012 edition"         =>"planechase 2012", 
                                "planechase 2012 edition (planes)"=>"planechase 2012", 
                                "planechase"                      =>"planechase", 
                                "planechase (planes)"             =>"planechase", 
                                "magic 2013"                      =>"magic 2013 (m13)", 
                                "magic 2012"                      =>"magic 2012 (m12)", 
                                "magic 2011"                      =>"magic 2011 (m11)", 
                                "tenth edition"                   =>"10th edition", 
                                "ninth edition"                   =>"9th edition", 
                                "eighth edition"                  =>"8th edition", 
                                "seventh edition"                 =>"7th edition", 
                                "classic (sixth edition)"         =>"classic sixth edition", 
                                "archenemy \"schemes\""           =>"archenemy", 
                                "judge reward promos"             =>"judge promos", 
                                "launch party promos"             =>"launch party cards", 
                                "media inserts"                   =>"media promos", 
                                "player rewards promos"           =>"magic player rewards", 
                                "prerelease promos"               =>"prerelease cards", 
                                "release promos"                  =>"release event cards", 
                                "commander arsenal"               =>"commander's arsenal", 
                                "holiday promos"                  =>"special occasion", 
                                "grand prix"                      =>"grand prix promos", 
                                "coldsnap theme decks"            =>"coldsnap", 
                                "arena league promos"             =>"arena promos", 
                                "premium deck series: fire & lightning"=>"premium deck series: fire and lightning",
                                "duel decks: knights vs. dragons" => "duel decks: knights vs dragons",
                                "beatdown"                        => "beatdown box set",
                                "battle royale"                   => "battle royale box set",
                                "portal I"                        => "portal",
                                "time shifted"                    => "timeshifted",
                                "ravnica: city of guilds"         => "ravnica", 
                                } 
                              

  if ENV['set_code'].present?
    sets_to_pull = Mtg::Set.where(:code => ENV['set_code'])
  else 
    sets_to_pull = Mtg::Set.all
  end
  
  sets_to_pull.each do |set|
    set_name = set.name    
    if set.cards.count > 0
      puts "Scraping data for: #{set_name}"
      if different_set_name_list[set_name.downcase].present?
        scrape_pricing_for_one_set(set_name, different_set_name_list[set_name.downcase])
      else
        scrape_pricing_for_one_set(set_name, set_name)
      end
    else
      puts "No cards to scrape for: #{set_name}"
    end
  end
  
  puts "Finished scraping pricing"      
  
end

def scrape_pricing_for_one_set(our_set_name = "", tcg_set_name = "")
  begin
    url = URI.escape "http://magic.tcgplayer.com/db/price_guide.asp?setname=#{tcg_set_name}"
    file = Nokogiri::HTML(open(url)) #open file containing block/set information
    card_info_hash = Hash.new

    file.css("table")[2].css("tr").each do |row| #for each row       
      card_name       = row.css("td")[0].text
      card_name[0]    = "" # TCGPlayer puts a space at the beginning of all names... let's remove that
      card_price_high = row.css("td")[5].text.gsub("$","").to_f.round(2)
      card_price_med  = row.css("td")[6].text.gsub("$","").to_f.round(2)
      card_price_low  = row.css("td")[7].text.gsub("$","").to_f.round(2)
      card_info_hash.merge!(card_name => {:price_low => card_price_low, :price_med => card_price_med, :price_high => card_price_high})
    end

    Mtg::Cards::Statistics.includes(:card => :set).where("mtg_sets.name LIKE ?", our_set_name).each do |stat|
      relative_pricing_factor_high = rand(0.90..0.95)
      relative_pricing_factor_low  = rand(0.82..0.88)    
      pricing_for_this_card = card_info_hash[stat.card.name]
      if pricing_for_this_card.present?
        if pricing_for_this_card[:price_low] == 0 || pricing_for_this_card[:price_med] == 0 || pricing_for_this_card[:price_low] == pricing_for_this_card[:price_high]
          puts "#{stat.card.set.name} - #{stat.card.name} - no pricing data on price sheet!!!"
          pricing_for_this_card = scrape_pricing_for_single_card(:statistics => stat, :tcg_set_name => tcg_set_name)
        end
        if pricing_for_this_card[:price_low] > 0 && pricing_for_this_card[:price_med] > 0
          stat.price_low  = (pricing_for_this_card[:price_low] * 100 * relative_pricing_factor_low).ceil / 100.to_f
          stat.price_high = (pricing_for_this_card[:price_med] * 100 * relative_pricing_factor_high).ceil / 100.to_f
          stat.price_med  = (( stat.price_low + stat.price_high ) / 2)
          stat.save if stat.changed?
        else
          puts "#{stat.card.set.name} - #{stat.card.name} - no pricing data even after trying to pull single card!!!"
        end
      else
        puts "#{stat.card.set.name} - #{stat.card.name} - was not present!!!"
      end
    end
  rescue
    puts "ERROR SCRAPING SET #{tcg_set_name}"
    return nil
  end
end

def scrape_pricing_for_single_card(options = {:statistics => nil, :tcg_set_name => nil})
  begin
    puts "Attempting to Scrape Pricing for single card: #{options[:statistics].card.name}"
  
    url = URI.escape "http://magic.tcgplayer.com/db/magic_single_card.asp?cn=#{options[:statistics].card.name}&sn=#{options[:tcg_set_name]}"
    file = Nokogiri::HTML(open(url))
  
    price_min     = 0
    price_average = 0
    price_nonfoil_array = []
    price_foil_array    = []  
  
    file.css("#StoreProducts").css("table")[0].css("tr").each do |row| #for each row
      if row.css("td")[2] #this is not a header row
        if row.css("td")[2].text.include?("Foil") # this is a foil card
          price_foil_array << row.css("td")[4].text.gsub("$","").to_f if row.css("td")[4]
        else
          price_nonfoil_array << row.css("td")[4].text.gsub("$","").to_f if row.css("td")[4]
        end
      end
    end rescue nil
  
    price_nonfoil_average = (price_nonfoil_array.inject { |sum, el| sum + el }.to_f / price_nonfoil_array.size) rescue 0
    price_foil_average    = (price_foil_array.inject    { |sum, el| sum + el }.to_f / price_foil_array.size)    rescue 0
  
    price_min     = (price_nonfoil_array.size > 1 ? price_nonfoil_array.min : price_foil_array.min)  rescue 0
    price_average = (price_nonfoil_array.size > 1 ? price_nonfoil_average   : price_foil_average)    rescue 0
    price_max     = (price_nonfoil_array.size > 1 ? price_nonfoil_array.max : price_foil_array.max)  rescue 0
  
    if ((price_min > 0 && price_average > 0 && price_max > 0) rescue false)
      return {:price_low => price_min, :price_med => price_average, :price_high => price_max}    
    else
      puts "Single Card Scraping NOT SUCCESSFUL!"
      return {:price_low => 0, :price_med => 0, :price_high => 0}    
    end
  rescue
    puts "ERROR SCRAPING CARD #{options[:statistics].card.name}"    
    return {}
  end
    
end