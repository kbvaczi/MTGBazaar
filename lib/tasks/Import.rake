namespace :import do

  namespace :mtg do

    desc "Update MTG sets from /db/mtg_data/sets.xml"
    task :sets => :environment do      
      puts "Importing MTG Sets..."      
      @file = Nokogiri::XML(open('db/mtg_data/mtg_sets.xml')) #open file containing block/set information      
      @file.css("blocks block").each do |b| #for each block       
        @block = MtgBlock.create(:name => b.css("block_name").text) #create a block in database
        puts "created block named #{@block.name}"
        b.css("sets set").each do |s| #for each set in this block
          @block.sets << MtgSet.create(:name => s.css("name").text, :code => s.css("code").text, :release_date => s.css("date").text) #create a new set and assign to current block
          puts "created set named #{s.css("name").text}"
        end  
      end  
    end
    
    desc "Update MTG cards from /db/mtg_data/cards.xml"
    task :cards => :sets do
    
      # do stuff here
      puts "called cards #{User.first.username}"
  
  
    end

  end

end