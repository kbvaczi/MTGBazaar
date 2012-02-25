ActiveAdmin.register MtgBlock do
  menu :label => "Blocks", :parent => "MTG"

  #access mtg_card helpers inside this class
  extend MtgCardsHelper

  scope :all, :default => true
  scope :active do |blocks|
    blocks.where(:active => true)
  end
  scope :inactive do |blocks|
    blocks.where(:active => false)
  end  
  
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |card|
      link_to card.id, admin_mtg_card_path(card)
    end
    column :name
    column :created_at
    column :updated_at    
    column :active
  end
end
