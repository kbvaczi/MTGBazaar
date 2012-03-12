# encoding: UTF-8
ActiveAdmin.register Mtg::Card do
  menu :label => "Cards", :parent => "MTG"

 
  #access mtg_card helpers inside this class
  extend Mtg::CardsHelper


  # ------ SCOPES ------- #
  begin
    scope :all, :default => true do |cards|
     cards.includes [:set, :block]
    end  
    scope :active do |cards|
      cards.joins(:set).where("mtg_cards.active LIKE ? AND mtg_sets.active LIKE ?", true, true)
    end
    scope :inactive do |cards|
      cards.joins(:set).where("mtg_cards.active LIKE ? OR mtg_sets.active LIKE ?", false, false)
    end  
  end
  
  # ------ INDEX ------- #
  # Customize columns displayed on the index screen in the table   
  begin
    index do
      column :id, :sortable => :id do |card|
        link_to card.id, admin_mtg_card_path(card)
      end
      column :name
      #column 'Block', :sortable => :'mtg_blocks.name' do |card|
      #  link_to card.block.name, admin_mtg_cards_path(:q => {:block_name_contains => card.block.name}, :scope => '')
      #end
      column 'Set', :sortable => :'mtg_sets.name'  do |card|
        link_to card.set.name, admin_mtg_set_path(card.set)
      end    
      column 'Set active?', :sortable => :'mtg_sets.active'  do |card|
        if card.set.active?
          "yes"
        else
          "no"
        end
      
      end    
      column :created_at
      column :updated_at
      column 'Card Active?', :active, :sortable => :active do |card|
        if card.set.active?
          if card.active?
            "yes"
          else
            "no"
          end
        else
          if card.active?
            "no (set inactive)"
          else
            "no"
          end
        end
      end
      column "Actions" do |card|
        "#{link_to('View', mtg_card_path(card), :target => "_blank")} #{link_to('Edit', edit_admin_mtg_card_path(card), :target => "_blank")}".html_safe
      end
    end
  end

  # ------ FILTERS FOR INDEX ------- #
  begin   
    filter :name
    #filter :block_name, :label => "Block", :as => :select, :collection => Mtg::Block.all.map(&:name), :input_html => {:class => "chzn-select"}
    filter :block, :as => :select, :input_html => {:class => "chzn-select"}  
    filter :set, :input_html => {:class => "chzn-select"}  
    filter :card_type, :as => :select, :collection => card_type_list, :input_html => {:class => "chzn-select"}
    filter :card_subtype, :as => :select, :collection => card_subtype_list, :input_html => {:class => "chzn-select"}
    filter :'mtg_sets.active'
  end 

  # ------ ACTION ITEMS (BUTTONS) ------- #  
  begin
    config.clear_action_items! #clear standard buttons
    action_item :only => :show do
      link_to 'View on site', mtg_card_path(mtg_card), :target => "_blank"
    end
    action_item :only => :show do
      link_to 'Edit Card', edit_admin_mtg_card_path(mtg_card)
    end    
    action_item :only => :show do
      link_to 'Delete Card', delete_card_admin_mtg_card_path(mtg_card), :confirm => "Are you sure you want to delete this card?"
    end
    action_item :only => :index do
      link_to 'Create New Card', new_admin_mtg_card_path
    end
    action_item :only => :index do
      link_to 'Import XML File', upload_xml_admin_mtg_cards_path
    end

  end
  
  # ------ CONTROLLER ACTIONS ------- #
  # note: collection_actions work on collections, member_acations work on individual 
  begin
    collection_action :upload_xml, :method => :get
    collection_action :process_xml, :method => :post do
      @block_data = Array.new  #initialize placeholders for uploaded data
      @set_data = Array.new
      @card_data = Array.new      
      @file = Nokogiri::XML(open(params[:attachment].tempfile)) #Open uploaded file
        
      puts "Importing MTG Sets..."
      #import blocks, sets
      @file.css("block").each do |b| #for each block
        #create block if none exists, otherwise select existing block that matches for child set/card creation       

        if Mtg::Block.where(:name => b.css("name")[0].text).count > 0 #if block already exists in database
          #@block = Mtg::Block.where(:name => b.css("name")[0].text)[0] #set instance object to the block
          puts "Block: #{b.css("name")[0].text} already exists!!!!" #do nothing
        else
          @block_data << {:name => b.css("name")[0].text, :active => true}
          #@block = Mtg::Block.create(:name => b.css("name")[0].text, :active => true) #create a block in database and set instance object
          puts "Block: #{b.css("name")[0].text} created"
        end

        #create sets if none exists, otherwise select existing matching set for child card creation
        b.css("set").each do |s| #for each set in this block   
          if Mtg::Set.where(:name => s.css("name").text).count > 0 #if set already exists in database
              puts "Set: #{s.css("name").text} already exists!!!!" #do nothing
          else
              @set_data << {:block => b.css("name")[0].text, :name => s.css("name").text, :code => s.css("code").text, :release_date => s.css("date").text, :active => false}
              #@block.sets << Mtg::Set.create(:name => s.css("name").text, :code => s.css("code").text, :release_date => s.css("date").text, :active => true) #create a new set and assign to current block
              puts "Set: #{s.css("name").text} created"
          end # if
        end # for each set
      end # for each block
      
      #import cards
      puts "Importing MTG Cards..."
      @file.css("cards card").each do |c| # for each card
        if Mtg::Card.where(:multiverse_id => c.css("id").text).count > 0 # if card already exists in database
          puts "Card: #{c.css("name").text} already exists!!!!" # do nothing
        else
          @card_data << { :set => c.css("set").text, 
                          :name => c.css("name").text, 
                          :card_type => compute_type(c.css("type").text),
                          :card_subtype => compute_subtype(c.css("type").text),
                          :card_number => format_number(c.css("number").text),
                          :rarity => c.css("rarity").text,
                          :artist => c.css("artist").text,
                          :description => c.css("ability").text,
                          :mana_string => c.css("manacost").text,
                          :mana_color => c.css("color").text,
                          :mana_cost => c.css("converted_manacost").text,
                          :power => c.css("power").text,
                          :toughness => c.css("toughness").text,
                          :multiverse_id => c.css("id").text,
                          :image_path => "https://s3.amazonaws.com/mtgbazaar/images/mtg/cards/#{c.css("set").text}/#{format_number(c.css("number").text)}.jpg",
                          :active => true }
          puts "Set: #{c.css("set").text}, Card: #{c.css("id").text}, #{c.css("name").text} created" # notification that card was created
        end # if card exists           
      end # for each card      
    
     Rails.cache.write("block_data",@block_data)
     Rails.cache.write("set_data",@set_data)
     Rails.cache.write("card_data",@card_data)          
    end # controller method
    collection_action :import_xml, :method => :post do
      @block_data = Rails.cache.read("block_data")
      @set_data = Rails.cache.read("set_data")
      @card_data = Rails.cache.read("card_data")
      @block_data.each do |b|
        Mtg::Block.create(:name => b[:name], :active => b[:active]) if Mtg::Block.where(:name => b[:name]).empty?
        puts "Block: #{b[:name]} created"
      end
      @set_data.each do |s|
        release_date = Date.strptime(s[:release_date], '%m/%Y') rescue nil
        block = Mtg::Block.where(:name => s[:block])[0]
        block.sets << Mtg::Set.create(:name => s[:name], :code => s[:code], :release_date => release_date, :active => false) if Mtg::Set.where(:code => s[:code]).empty?
        puts "Set: #{s[:name]} created"
      end
      @card_data.each do |c|
        set = Mtg::Set.where(:code => c[:set])[0]
        active = false #set card inactive if it's a new card in an old set (i.e. a set which is probably already active)
        @set_data.each do |s|
          if s[:code] == c[:set]
            active = true # this is part of a new set, so we will activate this card assuming the set will be deactivated
          end
        end
        set.cards << Mtg::Card.create(  :name => c[:name], 
                                        :card_type => c[:card_type],
                                        :card_subtype => c[:card_subtype],
                                        :card_number => c[:card_number],
                                        :rarity => c[:rarity],
                                        :artist => c[:artist],
                                        :description => c[:description],
                                        :mana_string => c[:mana_string],
                                        :mana_color => c[:mana_color],
                                        :mana_cost => c[:mana_cost],
                                        :power => c[:power],
                                        :toughness => c[:toughness],
                                        :multiverse_id => c[:multiverse_id],
                                        :image_path => c[:image_path],
                                        :active => active) if Mtg::Card.where(:multiverse_id => c[:multiverse_id]).empty?
        puts "Card: #{c[:name]} created"
      end      
      redirect_to admin_mtg_cards_path, :notice => "XML imported successfully!"              
    end #import_xml method
    member_action :delete_card do
      Mtg::Card.find(params[:id]).destroy
      respond_to do |format|
        format.html { redirect_to admin_mtg_cards_path, :notice => "Card Deleted..."}
      end
    end
    controller do
      before_filter :super_admin_authenticate, :only => :delete_card 
      
      def super_admin_authenticate
        authenticate_or_request_with_http_basic "This action requires special access" do |username, password|
          username == "superadmin" && password == "superadmin" 
        end 
      end
      
      def compute_type(string) #used to format type to import into cards.
        if string.split(" — ")[0]
          return string.split(" — ")[0].strip
        else
          return ""
        end  
      end #method

      def compute_subtype(string) #used to format subtype to import into cards
        if string.split(" — ")[1]
          return string.split(" — ")[1].strip
        else
          return ""
        end  
      end #method
      
      def format_number(number) #formats set number to be 3 digits long ex. 003a instead of 3a
        return "%03d" % number.to_i.to_s + number.delete(number.to_i.to_s)  
      end #method
    end
  end
  
end
