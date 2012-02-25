# encoding: UTF-8



namespace :mtg do

  namespace :import do
    
    ######## IMPORT MTG SETS ########
    desc "Update MTG sets from /db/mtg_data/sets.xml"
    task :sets => :environment do      
      @blocks_created = 0
      @sets_created = 0
      puts "Importing MTG Sets..."      
      @file = Nokogiri::XML(open('db/mtg_data/mtg_sets.xml')) #open file containing block/set information      
      
      @file.css("blocks block").each do |b| #for each block       
        
        if MtgBlock.where(:name => b.css("name")[0].text).count > 0 #if block already exists in database
          @block = MtgBlock.where(:name => b.css("name")[0].text)[0] #set instance object to the block
          puts "Block: #{b.css("name")[0].text} already exists!!!!" #do nothing
        else
          @block = MtgBlock.create(:name => b.css("name")[0].text, :active => true) #create a block in database and set instance object
          puts "Block: #{@block.name} created"
          @blocks_created = @blocks_created + 1
        end
        
        b.css("set").each do |s| #for each set in this block   
         if MtgSet.where(:name => s.css("name").text).count > 0 #if set already exists in database
            puts "Set: #{s.css("name").text} already exists!!!!" #do nothing
          else
            @block.sets << MtgSet.create(:name => s.css("name").text, :code => s.css("code").text, :release_date => s.css("date").text, :active => true) #create a new set and assign to current block
            puts "Set: #{s.css("name").text} created"
            @sets_created = @sets_created + 1
          end # if
        end # for each set
          
      end # for each block
       puts "Blocks Created: #{@blocks_created.to_s}"
       puts "Sets Created: #{@sets_created.to_s}"       
    end # task

    ######## IMPORT MTG CARDS ########
    # assumptions: all blocks and sets are included in sets import
    desc "Update MTG cards from /db/mtg_data/cards/mtg_cards.xml"
    task :cards => :sets do
      @cards_created = 0
      puts "Importing MTG Cards..."
      @file = Nokogiri::XML(open('db/mtg_data/cards/mtg_cards.xml')) #open file containing card information
      
      @file.css("cards card").each do |c| # for each card

        if MtgCard.where(:multiverse_id => c.css("id").text).count > 0 # if card already exists in database
          puts "Card: #{c.css("name").text} already exists!!!!" # do nothing
        else
          @set = MtgSet.where(:code => c.css("set").text)[0] # otherwise, look up the set which the card belongs to
          number = c.css("number").text
          formatted_number = "%03d" % number.to_i.to_s + number.delete(number.to_i.to_s)
          @set.cards << MtgCard.create( 
                                        :name => c.css("name").text, 
                                        :card_type => compute_type(c.css("type").text),
                                        :card_subtype => compute_subtype(c.css("type").text),
                                        :card_number => formatted_number,
                                        :rarity => c.css("rarity").text,
                                        :artist => c.css("artist").text,
                                        :description => c.css("ability").text,
                                        :mana_string => c.css("manacost").text,
                                        :mana_color => c.css("color").text,
                                        :mana_cost => c.css("converted_manacost").text,
                                        :power => c.css("power").text,
                                        :toughness => c.css("toughness").text,
                                        :legality_block => c.css("legality_Block").text,
                                        :legality_standard => c.css("legality_Standard").text,
                                        :legality_extended => c.css("legality_Extended").text,
                                        :legality_modern => c.css("legality_Modern").text,
                                        :legality_legacy => c.css("legality_Legacy").text,
                                        :legality_vintage => c.css("legality_Vintage").text,
                                        :legality_highlander => c.css("legality_Highlander").text,
                                        :legality_french_commander => c.css("legality_French_Commander").text,
                                        :legality_commander => c.css("legality_Commander").text,
                                        :legality_peasant => c.css("legality_Peasant").text,
                                        :legality_pauper => c.css("legality_Pauper").text,
                                        :multiverse_id => c.css("id").text,
                                        :image_path => "mtg/cards/#{c.css("set").text}/#{formatted_number}.jpg",
                                        :active => true
                                      ) # create the card under its corresponding set
                         
          puts "Set: #{@set.name}, Card: #{c.css("id").text}, #{c.css("name").text} created" # notification that card was created
          @cards_created = @cards_created + 1
        end # if card exists           
        
      end # for each card
      
      puts "Cards created: #{@cards_created.to_s}" #let us know how many cards we created
      
    end # task

  

  end # namespace import

  #lists all available color codes
  task :activate_all => :environment do
    MtgBlock.all.each do |b|
      b.active = true
      b.save      
      b.sets.all.each do |s|
        s.active = true
        s.save
        s.cards.each do |c|
          c.active = true
          c.save
        end
      end
    end
    puts "everything activated"
  end

  #lists all available color codes
  task :list_colors => :environment do
   @array = Array.new
    MtgCard.all.each do |c|
      @array << c.mana_color
    end
    puts @array.uniq
  end
  
  #lists all available rarities
  task :list_rarities => :environment do
   @array = Array.new
    MtgCard.all.each do |c|
      @array << c.rarity
    end
    puts @array.uniq
  end
  
  #lists all available legality codes
  task :list_legalities => :environment do
   @array = Array.new
    MtgCard.all.each do |c|
      @array << c.legality_standard
      @array << c.legality_commander  
      @array << c.legality_highlander
      @array << c.legality_peasant                            
      @array << c.legality_pauper      
      @array << c.legality_french_commander      
      @array << c.legality_block
      @array << c.legality_vintage
      @array << c.legality_modern
      @array << c.legality_extended                  
      @array << c.legality_legacy      
    end
    puts @array.uniq
  end


  task :convert_names => :environment do
    MtgCard.all.each do |c|
      before = c.card_number
      if c.card_number.length > 0
        numeral = c.card_number.match(/[0-9]+/)[0]
        numeral = "0" + numeral if numeral.length < 3
        numeral = "0" + numeral if numeral.length < 3      
        letter = c.card_number.match(/[a-z]+/)
        if letter
          letter = letter[0]
        else
          letter = ""
        end
        new_value = numeral + letter
        c.update_attribute(:card_number, new_value)
        c.update_attribute(:image_path, "mtg/cards/#{c.set.code}/#{c.card_number}.jpg")
        after = new_value
        puts "ID: #{c.id} before: #{before} - After #{after}"
      end
    end
  end

end # namespace mtg

  
def compute_type(string) #used to format type to import into cards.
  if string.split(" — ")[0]
    return string.split(" — ")[0].strip
  else
    return ""
  end  
end

def compute_subtype(string) #used to format subtype to import into cards
  if string.split(" — ")[1]
    return string.split(" — ")[1].strip
  else
    return ""
  end  
end