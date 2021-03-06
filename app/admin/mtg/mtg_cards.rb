# encoding: UTF-8
ActiveAdmin.register Mtg::Card do
  menu :label => "3 - Cards", :parent => "MTG"

  #access mtg_card helpers inside this class
  extend Mtg::CardsHelper


  # ------ SCOPES ------- #
  begin
    scope :all, :default => true do |cards|
     cards.includes [:set, :statistics]
    end  
    scope :active do |cards|
      cards.includes(:set, :statistics).where("mtg_cards.active LIKE ? AND mtg_sets.active LIKE ?", true, true)
    end
    scope :inactive do |cards|
      cards.includes(:set, :statistics).where("mtg_cards.active LIKE ? OR mtg_sets.active LIKE ?", false, false)
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
        link_to display_set_symbol(card.set), admin_mtg_set_path(card.set)
      end
      column 'rarity', :sortable => :rarity do |card|
        display_rarity(card.rarity)
      end
      column 'For Sale', :sortable => 'mtg_card_statistics.listings_available' do |card|
        link_to card.statistics.listings_available, admin_mtg_cards_listings_path('q[card_name_contains]' => card.name)
      end
      column 'Sales', :sortable => :'mtg_card_statistics.number_sales' do |card| 
        link_to card.statistics.number_sales, admin_mtg_transactions_items_path('q[card_name_contains]' => card.name)
      end
      column '$ low', :sortable => :'mtg_card_statistics.price_low' do |card|
        card.statistics.price_low
      end
      column '$ med', :sortable => :'mtg_card_statistics.price_med' do |card|
        card.statistics.price_med
      end      
      column '$ high', :sortable => :'mtg_card_statistics.price_high' do |card|
        card.statistics.price_high
      end        
      column :created_at
      column :updated_at
      column 'Set active?', :sortable => :'mtg_sets.active'  do |card|
        if card.set.active?
          status_tag "Yes", :ok
        else
          status_tag "No", :error
        end
      end      
      column 'Card Active?', :active, :sortable => :active do |card|
        if card.set.active?
          if card.active?
              status_tag "Yes", :ok
            else
              status_tag "No", :error
          end
        else
          if card.active?
              status_tag "No", :warning, :title => "set inactive"
            else
              status_tag "No", :error, :title => "set inactive"
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
    filter :name, :label => "Card Name", :as => :string, :input_html => {:class => "ui-autocomplete-input" , "data-type" => "search", "data-autocomplete" => '/mtg/cards/autocomplete_name.json' }
    filter :block,        :as => :select,                                   :input_html => {:class => "chzn-select"}  
    filter :set,                                                            :input_html => {:class => "chzn-select"}  
    filter :card_type,    :as => :select, :collection => Proc.new {card_type_list},    :input_html => {:class => "chzn-select"}
    filter :card_subtype, :as => :select, :collection => Proc.new {card_subtype_list}, :input_html => {:class => "chzn-select"}
    filter :set_active,   :as => :select,                                   :input_html => {:class => "chzn-select"}
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
      link_to "#{mtg_card.active ? "Deactivate Card" : "Activate Card"}", toggle_active_admin_mtg_card_path(mtg_card), :confirm => "Are you sure you want to change active status on this card?"
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
  
  
  # ------ FORM --------------------- #
  
  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :set,           :hint => "Card must go in an existing set.  Create a new set first if necessary.",
                              :input_html => {:class => "chzn-select"},
                              :required => true
      f.input :card_type,     :as => :select,
                              :collection => card_type_list,
                              :input_html => {:class => "chzn-select", :style => "width:250px;"},
                              :hint => "If type not in list, add to card_type_list method under cards helper",
                              :required => true
      f.input :card_subtype,  :as => :select,
                              :collection => card_subtype_list,
                              :input_html => {:class => "chzn-select", :style => "width:250px;"},
                              :hint => "If type not in list, add to card_subtype_list method under cards helper",
                              :required => true
      f.input :rarity,        :as => :select,
                              :collection => rarity_list,
                              :input_html => {:class => "chzn-select", :style => "width:250px;"},
                              :hint => "If type not in list, add to rarity_list method under cards helper",
                              :required => true
      f.input :artist,        :as => :select,
                              :collection => artist_list,
                              :input_html => {:class => "chzn-select", :style => "width:250px;"},
                              :hint => "If type not in list, add to artist_list method under cards helper",
                              :required => true
      f.input :description,   :hint => "See symbols file names on S3 for displaying symbols"
      f.input :mana_string,   :hint => "See symbols file names on S3 for displaying symbols"
      f.input :mana_color,    :hint => "\'L\' = Land, \'U\' = Blue, \'B\' = Black, \'W\' = White, \'R\' = Red, \'G\' = Green, \'S\' = Scheme, \'C\' = Colorless, \'P\' = Plane, \'A\' = Artifact, \'(H)\' = Hybrid" 
      f.input :mana_cost,     :as => :number
      f.input :power,     :as => :number
      f.input :toughness,     :as => :number
      f.input :image_path,    :hint => "example: https://s3.amazonaws.com/mtgbazaar/images/mtg/cards/DKA/140a.jpg"
      f.input :card_number,     :as => :number
    end
    f.buttons
  end
  
  # ------ CONTROLLER ACTIONS ------- #
  # note: collection_actions work on collections, member_acations work on individual 
  begin
    collection_action :upload_xml, :method => :get
    
    # PROCESS XML DATA ------------------- #
    
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
                          :price_low => c.css("pricing_low").text,                          
                          :price_med => c.css("pricing_mid").text,                                                    
                          :price_high => c.css("pricing_high").text,                                                    
                          :image_path => "https://s3.amazonaws.com/mtgbazaar/images/mtg/cards/#{c.css("set").text}/#{format_number(c.css("number").text)}.jpg",
                          :active => true }
          puts "Set: #{c.css("set").text}, Card: #{c.css("id").text}, #{c.css("name").text} created" # notification that card was created
        end # if card exists           
      end # for each card      
    
     Rails.cache.write("block_data", @block_data, :timeToLive => 1200.seconds) #saves data in cache for 20 minutes
     Rails.cache.write("set_data", @set_data, :timeToLive => 1200.seconds)#saves data in cache for 20 minutes
     Rails.cache.write("card_data", @card_data, :timeToLive => 1200.seconds)#saves data in cache for 20 minutes          
    end # controller method
    
    # IMPORT XML DATA ------------------- #
    
    collection_action :import_xml, :method => :post do
      @block_data = Rails.cache.read("block_data")
      @set_data = Rails.cache.read("set_data")
      @card_data = Rails.cache.read("card_data")
      @block_data.each do |b|
        if Mtg::Block.where(:name => b[:name]).empty?
          Mtg::Block.create(:name => b[:name], :active => b[:active]) 
          puts "Block: #{b[:name]} created"
        else
          puts "Block: #{b[:name]} DUPLICATE!!!"
        end
        
      end
      @set_data.each do |s|
        release_date = Date.strptime(s[:release_date], '%m/%Y') rescue nil
        block = Mtg::Block.where(:name => s[:block])[0]
        if Mtg::Set.where(:code => s[:code]).empty?
          block.sets << Mtg::Set.create(:name => s[:name], :code => s[:code], :release_date => release_date, :active => false) 
          puts "Set: #{s[:name]} created"
        else
          puts "Set: #{s[:name]} DUPLICATE!!!"
        end
      end
      @card_data.each do |c|
        set = Mtg::Set.where(:code => c[:set])[0]
        active = false #set card inactive if it's a new card in an old set (i.e. a set which is probably already active)
        @set_data.each do |s|
          if s[:code] == c[:set]
            active = true # this is part of a new set, so we will activate this card assuming the set will be deactivated
          end
        end
        if Mtg::Card.where(:multiverse_id => c[:multiverse_id]).empty?
          if Mtg::Card.create(  :set_id => set.id,
                                :name => c[:name], 
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
                                :price_low => c[:price_low],                          
                                :price_med => c[:price_med],                                                    
                                :price_high => c[:price_high],                                        
                                :image_path => c[:image_path],
                                :active => active) 
            puts "Card: #{c[:name]} created"
          else
            puts "card error"
          end
        else
          puts "Card: #{c[:name]} DUPLICATE!!!"
        end
      end      
      redirect_to admin_mtg_cards_path, :notice => "XML imported successfully!"              
    end #import_xml method
    
    member_action :delete_card do
      Mtg::Card.find(params[:id]).destroy
      respond_to do |format|
        format.html { redirect_to admin_mtg_cards_path, :notice => "Card Deleted..."}
      end
    end
    
    member_action :toggle_active do
      card = Mtg::Card.find(params[:id])
      card.update_attribute(:active, !card.active)
      respond_to do |format|
        format.html { redirect_to admin_mtg_card_path(card), :notice => "Card is Now #{card.active ? "Active" : "Inactive"}..."}
      end
    end
    
    controller do
      
      def compute_type(string) #used to format type to import into cards.
        if string.split(" ??? ")[0]
          return string.split(" ??? ")[0].strip
        else
          return ""
        end  
      end #method

      def compute_subtype(string) #used to format subtype to import into cards
        if string.split(" ??? ")[1]
          return string.split(" ??? ")[1].strip
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
