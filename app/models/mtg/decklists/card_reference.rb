class Mtg::Decklists::CardReference < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'mtg_decklists_card_references'
  belongs_to :decklist,  :class_name => 'Mtg::Decklists', :foreign_key => 'decklist_id'  
  belongs_to :card,      :class_name => 'Mtg::Card',      :foreign_key => 'card_id'
  
  attr_accessor :unprocessed_section
  
  # ----- Validations ----- #

  validates_presence_of :card
  validates_presence_of :deck_section

  # ----- Callbacks ----- #    

  before_validation :set_card_id
  before_validation :set_sections
  
  def set_card_id
    self.card_id = Mtg::Card.joins(:set).active.where(:name => self.card_name).order('mtg_sets.release_date DESC').limit(1).value_of(:id).first
  end
  
  def set_sections
    case self.unprocessed_section
      when /Sideboard/i
        self.deck_section     = 'Sideboard'
        self.deck_subsection  = ''
      when /Lands/i
        self.deck_section     = 'Main Deck'
        self.deck_subsection  = 'Lands'        
      when /Creatures/i
        self.deck_section     = 'Main Deck'
        self.deck_subsection  = 'Creatures'        
      when /Spells/i
        self.deck_section     = 'Main Deck'
        self.deck_subsection  = 'Spells'        
      else
        self.deck_section     = 'Main Deck'
        self.deck_subsection  = ''        
    end
  end

  # ----- Scopes ------ #
  

  
  # ----- Instance Methods ----- #


  
  # ----- Class Methods    ----- #  
  
end