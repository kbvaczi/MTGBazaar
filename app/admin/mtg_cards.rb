ActiveAdmin.register MtgCard do
  menu :label => "Cards", :parent => "MTG"

  #access mtg_card helpers inside this class
  extend MtgCardsHelper

  scope :all, :default => true do |cards|
   cards.includes [:set, :block]
  end
  
  # Customize columns displayed on the index screen in the table
  index do
    column :id
    column :name, :sortable => :name do |card|
      link_to card.name, admin_mtg_card_path(card)
    end
    column 'Block', :sortable => :'mtg_blocks.name' do |card|
      link_to card.block.name, admin_mtg_cards_path(:q => {:block_name_contains => card.block.name}, :scope => '')
    end
    column 'Set', :sortable => :'mtg_sets.name'  do |card|
      card.set.name
    end    
    column :card_type
    column :card_subtype
  end
  
  filter :name
  filter :block_name, :label => "Block", :as => :select, :collection => MtgBlock.all.map(&:name), :input_html => {:class => "chzn-select"}
  filter :set, :input_html => {:class => "chzn-select"}  
  filter :card_type, :as => :select, :collection => card_type_list, :input_html => {:class => "chzn-select"}
  filter :card_subtype, :as => :select, :collection => card_subtype_list, :input_html => {:class => "chzn-select"}

end
