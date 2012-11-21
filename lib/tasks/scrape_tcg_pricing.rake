# encoding: UTF-8
#
# USAGE
# To Scrape one set:  rake scrape_tcg_pricing set_code=XXX (where XXX is a single set you want to scrape...)
# To Scrape all sets: rake scrape_tcg_pricing

task :scrape_tcg_pricing => :environment do 
  
  include Mtg::CardsHelper
  
  puts "Starting to scrape pricing"
  
  #these are the sets that tcgplayer calles something else than we do
  different_set_name_list = { "Limited Edition Beta"              => "Beta Edition",
                              "Limited Edition Alpha"             => "Alpha Edition",
                              "Planechase 2012 Edition"           => "Planechase 2012",
                              "Planechase 2012 Edition (Planes)"  => "Planechase 2012",
                              "Planechase"                        => "Planechase",
                              "Planechase (Planes)"               => "Planechase",
                              "Magic 2013"                        => "Magic 2013 (M13)",
                              "Magic 2012"                        => "Magic 2012 (M12)",
                              "Magic 2011"                        => "Magic 2011 (M11)",
                              "Tenth Edition"                     => "10th Edition",
                              "Ninth Edition"                     => "9th Edition",
                              "Eighth Edition"                    => "8th Edition",
                              "Seventh Edition"                   => "7th Edition",
                              "Classic (Sixth Edition)"           => "Classic Sixth Edition" }

  if ENV['set_code'].present?
    sets_to_pull = Mtg::Set.where(:code => ENV['set_code'])
  else 
    sets_to_pull = Mtg::Set.all
  end
  
  sets_to_pull.each do |set|
    set_name = set.name    
    if set.cards.count > 0
      puts "Scraping data for: #{set_name}"
      if different_set_name_list[set_name].present?
        scrape_pricing_for_one_set(set_name, different_set_name_list[set_name])
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
  url = "http://magic.tcgplayer.com/db/price_guide.asp?setname=" + tcg_set_name.gsub(" ", "%20")    
  file = Nokogiri::HTML(open(url)) #open file containing block/set information
  card_info_hash = Hash.new

  file.css("table")[2].css("tr").each do |row| #for each block       
    card_name       = row.css("td")[0].text
    card_name[0]    = ""
    card_price_high = row.css("td")[5].text.gsub("$","").to_f
    card_price_high -= rand(10).to_f/100 if card_price_high >= 0.50
    card_price_med  = row.css("td")[6].text.gsub("$","").to_f
    card_price_med  -= rand(05).to_f/100 if card_price_med  >= 0.25    
    card_price_low  = row.css("td")[7].text.gsub("$","").to_f        
    card_price_low  -= rand(03).to_f/100 if card_price_low  >= 0.10        
    card_info_hash.merge!(card_name => {:price_low => card_price_low, :price_med => card_price_med, :price_high => card_price_high})
  end

  Mtg::Cards::Statistics.includes(:card => :set).where("mtg_sets.name LIKE ?", our_set_name).each do |stat|
    pricing_for_this_card = card_info_hash[stat.card.name]
    if pricing_for_this_card.present?
      stat.price_low = pricing_for_this_card[:price_low] if pricing_for_this_card[:price_low] > 0
      stat.price_med = pricing_for_this_card[:price_med] if pricing_for_this_card[:price_med] > 0   
      stat.price_high = pricing_for_this_card[:price_high] if pricing_for_this_card[:price_high] > 0            
      if stat.changed?
        stat.save 
      else
        puts "#{stat.card.set.name} - #{stat.card.name} - no pricing data!!!"        
      end
    else
      puts "#{stat.card.set.name} - #{stat.card.name} - was not present!!!"
    end
  end

end