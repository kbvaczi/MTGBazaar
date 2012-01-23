namespace :import do

  namespace :mtg do

    desc "Update MTG sets from /db/mtg_data/sets.xml"
    task :sets => :environment do      
      puts "Importing MTG Sets..."      
      @file = Nokogiri::XML(open('db/mtg_data/mtg_sets.xml')) #open file containing block/set information      
      
      @file.css("blocks block").each do |b| #for each block       
        
        if MtgBlock.where(:name => b.css("name")[0].text) #if block already exists in database
          @block = MtgBlock.where(:name => b.css("name")[0].text)[0] #set instance object to the block
          puts "Block: #{b.css("name")[0].text} already exists!!!!" #do nothing
        else
          @block = MtgBlock.create(:name => b.css("name")[0].text) #create a block in database and set instance object
          puts "Block: #{@block.name} created"
        end
        
        b.css("set").each do |s| #for each set in this block   
         if MtgSet.where(:name => s.css("name")[0].text) #if set already exists in database
            puts "Set: #{s.css("name")[0].text} already exists!!!!" #do nothing
          else
            @block.sets << MtgSet.create(:name => s.css("name").text, :code => s.css("code").text, :release_date => s.css("date").text) #create a new set and assign to current block
            puts "Set: #{s.css("name").text} created"
          end          
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