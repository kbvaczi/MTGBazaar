class Mtg::Decklists::CardReference < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'mtg_decklists_card_references'
  belongs_to :decklist,  :class_name => 'Mtg::Decklists', :foreign_key => 'decklist_id'  
  belongs_to :card,      :class_name => 'Mtg::Card',      :foreign_key => 'card_id'
  
  # ----- Validations ----- #

  validates_presence_of :card
  validates_presence_of :deck_section

  # ----- Callbacks ----- #    

  before_save :set_card_name
  
  def set_card_name
    self.card_name = self.card.name if self.card.present?
  end

  # ----- Scopes ------ #
  

  
  # ----- Instance Methods ----- #


  
  # ----- Class Methods    ----- #  
  
end