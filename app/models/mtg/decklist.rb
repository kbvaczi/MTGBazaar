class Mtg::Decklist < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'mtg_decklists'
  
  has_many   :card_references,  :class_name => 'Mtg::Decklists::CardReference', :foreign_key => 'decklist_id', :dependent => :destroy
  has_many   :cards,            :class_name => 'Mtg::Card',                     :through => :card_references,  :source => :card
  
  # allow form for accounts nested inside user signup/edit forms
  accepts_nested_attributes_for :card_references, :reject_if => lambda { |a| a[:card_name].blank? || a[:quantity].blank? }, :allow_destroy => true
      
  attr_accessor :decklist_text_main, :decklist_text_sideboard
  
  # ----- Validations ----- #
  validates_uniqueness_of :name
  validates_presence_of   :card_references
  validates_associated    :card_references

  # ----- Callbacks ----- #    

  before_validation :import_deck_from_text
  
  def import_deck_from_text
    if self.decklist_text_main.present?
      self.decklist_text_main.each_line do |line|
        split_line = line.strip.partition(/\d+/)
        next if split_line[0].include?('//') or split_line[1].empty? or split_line[2].empty?
        quantity   = split_line[1].to_i
        card_name  = split_line[2].strip
        self.card_references.build(:quantity => quantity, :card_name => card_name)
      end
    end
    if self.decklist_text_main.present? && self.decklist_text_sideboard.present?
      self.decklist_text_sideboard.each_line do |line|
        split_line = line.strip.partition(/\d+/)
        next if split_line[0].include?('//') or split_line[1].empty? or split_line[2].empty?
        quantity   = split_line[1].to_i
        card_name  = split_line[2].strip
        self.card_references.build(:quantity => quantity, :card_name => card_name, :unprocessed_section => 'Sideboard')
      end
    end    
  end

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
  
  def cards_count
    self.cards.count
  end
  
  def cards_count_lands
    self.get_cards(:subsection => 'Lands').count
  end  

  def cards_count_spells
    self.get_cards(:subsection => 'Spells').count
  end  
  
  def cards_count_creatures
    self.get_cards(:subsection => 'Creatures').count
  end  
  
  def cards_count_sideboard
    self.get_cards(:section => 'Sideboard').count
  end  
  
  # ----- Class Methods    ----- #  
  
end