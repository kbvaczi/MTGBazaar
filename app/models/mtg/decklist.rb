class Mtg::Decklist < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'mtg_decklists'
  
  has_many   :card_references,  :class_name => 'Mtg::Decklists::CardReference', :foreign_key => 'decklist_id', :dependent => :destroy
  has_many   :cards,            :class_name => 'Mtg::Card',                     :through => :card_references,  :source => :card
  
  # ----- Validations ----- #
  validates_uniqueness_of :name
  validates_presence_of   :card_references
  validates_associated    :card_references


  # ----- Callbacks ----- #    

  # ----- Scopes ------ #
  
  def self.active
    where("mtg_decklists.active" => true)
  end

  # ----- Instance Methods ----- #
  
  def get_cards(options ={})
    options = {:section => nil, :subsection => nil}.merge(options)
    query   = SmartTuple.new(" AND ")
    query  << ["mtg_decklists_card_references.deck_section LIKE ?", options[:section]] if options[:section].present?
    query  << ["mtg_decklists_card_references.deck_subsection LIKE ?", options[:subsection]] if options[:subsection].present?    
    self.cards.where(query.compile)
  end
  
  # ----- Class Methods    ----- #  
  
end