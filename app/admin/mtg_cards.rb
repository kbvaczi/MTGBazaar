ActiveAdmin.register MtgCard do
  
  # Create sections on the index screen
  #scope :all, :default => true
  
  scope :all, :default => true do |mtg_cards|
    mtg_cards.includes [:set, :block]
  end
  
  # Customize columns displayed on the index screen in the table
  index do
    column :name, :sortable => :name do |name|
      link_to MtgCard.name, admin_mtg_card_path(name)
    end
  end

end
