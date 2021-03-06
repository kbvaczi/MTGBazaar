class Mtg::Decklists::CardReference < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'mtg_decklists_card_references'
  belongs_to :decklist,  :class_name => 'Mtg::Decklists', :foreign_key => 'decklist_id'  
  belongs_to :card,      :class_name => 'Mtg::Card',      :foreign_key => 'card_id'
  
  attr_accessor :unprocessed_section
  
  # ----- Validations ----- #

  validates_presence_of :deck_section, :message => "Cards must be in Main Deck or Sideboard"
  validates             :quantity, :numericality => {:greater_than => 0, :message => "Quantity for cards must be at least 1"}
  validate :validate_card_presence
  
  def validate_card_presence
    unless self.card_id.present?
      errors.add(:card_name, "Could not find card named #{self.card_name}")
    end
  end
  
  # ----- Callbacks ----- #    

  before_validation :set_card_id
  before_validation :correct_card_name
  before_validation :set_sections
  
  def set_card_id
    self.card_id = Mtg::Card.joins(:set).active.where('mtg_cards.name LIKE ?', self.card_name).order('mtg_sets.release_date DESC').limit(1).value_of(:id).first
  end
  
  def correct_card_name
    self.card_name = self.card.name if self.card.present?

  end
  
  def set_sections                
    case self.deck_section
      when /Sideboard/i
        self.deck_section     = 'Sideboard'
        self.deck_subsection  = processed_subsection
      else
        self.deck_section     = 'Main Deck'
        self.deck_subsection  = processed_subsection
    end
  end

  # ----- Scopes ------ #
  
  def self.main_deck
    where(:deck_section => 'Main Deck')
  end

  def self.sideboard
    where(:deck_section => 'Sideboard')
  end
  
  # ----- Instance Methods ----- #

  def processed_subsection
    begin
      case self.card.card_type
        # check for lands first... anything but enchant land is legal      
        when /\A^((?!enchant).)*land/ix
          'Lands'
        when /creature/ix
          'Creatures'
        else
          'Other Spells'
      end
    rescue
      ''
    end
  end
  
  # ----- Class Methods    ----- #  
  
end