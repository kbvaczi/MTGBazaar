ActiveAdmin.register MtgBlock do
  menu :label => "Blocks", :parent => "MTG"

  #access mtg_card helpers inside this class
  extend MtgCardsHelper

  scope :all, :default => true
  
end
