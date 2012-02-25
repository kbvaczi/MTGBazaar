ActiveAdmin.register MtgCard do
  menu :label => "Cards", :parent => "MTG"

  #access mtg_card helpers inside this class
  extend MtgCardsHelper

  scope :all, :default => true do |cards|
   cards.includes [:set, :block]
  end  
  scope :active do |cards|
    cards.joins(:set).where("mtg_cards.active LIKE ? AND mtg_sets.active LIKE ?", true, true)
  end
  scope :inactive do |cards|
    cards.joins(:set).where("mtg_cards.active LIKE ? OR mtg_sets.active LIKE ?", false, false)
  end  

  
  # Customize columns displayed on the index screen in the table
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
    column 'Active?', :active, :sortable => :active do |card|
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
      "#{link_to('View on site', mtg_card_path(card), :target => "_blank")} #{link_to('Show', admin_mtg_card_path(card))} #{link_to('Edit', edit_admin_mtg_card_path(card), :target => "_blank")}".html_safe
    end
  end
  
  filter :name
  #filter :block_name, :label => "Block", :as => :select, :collection => MtgBlock.all.map(&:name), :input_html => {:class => "chzn-select"}
  filter :block, :as => :select, :input_html => {:class => "chzn-select"}  
  filter :set, :input_html => {:class => "chzn-select"}  
  filter :card_type, :as => :select, :collection => card_type_list, :input_html => {:class => "chzn-select"}
  filter :card_subtype, :as => :select, :collection => card_subtype_list, :input_html => {:class => "chzn-select"}
  filter :'mtg_sets.active'

  action_item :only => :show do
    link_to('View on site', mtg_card_path(mtg_card), :target => "_blank")
  end
  
end
