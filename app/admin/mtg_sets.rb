ActiveAdmin.register MtgSet do
  menu :label => "Sets", :parent => "MTG"

  #access mtg_card helpers inside this class
  extend MtgCardsHelper

  scope :all, :default => true
  scope :active do |sets|
    sets.where(:active => true)
  end
  scope :inactive do |sets|
    sets.where(:active => false)
  end  
  
  
  # Customize columns displayed on the index screen in the table
  index do
    column :id, :sortable => :id do |set|
      link_to set.id, admin_mtg_set_path(set)
    end
    column :name
    column :code
    column :release_date
    column :created_at
    column :updated_at    
    column :active
  end
  
end