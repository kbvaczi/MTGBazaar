ActiveAdmin.register MtgSet do
  menu :label => "Sets", :parent => "MTG"

  #access mtg_card helpers inside this class
  extend MtgCardsHelper

  scope :all, :default => true
  
end