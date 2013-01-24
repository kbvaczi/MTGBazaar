class Mtg::Decklist < ActiveRecord::Base
  # ----- Table Setup ----- #

  self.table_name = 'mtg_decklists'
  
  has_many   :card_references,  :class_name => 'Mtg::Decklists::CardReference', :foreign_key => 'decklist_id', :dependent => :destroy
  has_many   :cards,            :class_name => 'Mtg::Card',                     :through => :card_references,  :source => :card
  
  # allow form for accounts nested inside user signup/edit forms
  accepts_nested_attributes_for :card_references, :reject_if => lambda { |a| a[:card_name].blank? || a[:quantity].blank? }, :allow_destroy => true
      
  attr_accessor :decklist_text_main, :decklist_text_sideboard, :card_references_to_destroy_after_update
  
  # ----- Validations ----- #
  validates_presence_of :card_references, :message => "You need at least one card in a decklist"

  # ----- Callbacks ----- #    

  before_validation :import_deck_from_text
  before_update     :manage_changes_from_text
  before_save       :generate_mana_string
  
  def import_deck_from_text
    if self.decklist_text_main.present?
      self.decklist_text_main.each_line do |line|
        split_line = line.strip.partition(/\d+/)
        next if split_line[0].include?('//') or split_line[1].empty? or split_line[2].empty?
        quantity   = split_line[1].to_i
        card_name  = split_line[2].strip.squeeze(" ")
        self.card_references.build(:quantity => quantity, :card_name => card_name)
      end
    end
    if self.decklist_text_main.present? && self.decklist_text_sideboard.present?
      self.decklist_text_sideboard.each_line do |line|
        split_line = line.strip.partition(/\d+/)
        next if split_line[0].include?('//') or split_line[1].empty? or split_line[2].empty?
        quantity   = split_line[1].to_i
        card_name  = split_line[2].strip.squeeze(" ")
        self.card_references.build(:quantity => quantity, :card_name => card_name, :unprocessed_section => 'Sideboard')
      end
    end    
  end
  
  def manage_changes_from_text
    card_references_to_destroy_after_update ||= []
    self.card_references.main_deck.group_by(&:card_name).each do |card_name, card_references_with_this_name|
      if card_references_with_this_name.count == 1 # only 1 by this name, it's either new or deleted
        # if it is a new record, it's newly created, otherwise it's no longer in the text list and needs to be deleted        
        card_references_to_destroy_after_update << card_references_with_this_name.first.id unless card_references_with_this_name.first.new_record? 
      else
        # delete the old ones as the new ones will replace them
        card_references_with_this_name.to_a.each {|a| card_references_to_destroy_after_update << a.id if a.id.present? }
      end      
    end
    self.card_references.sideboard.group_by(&:card_name).each do |card_name, card_references_with_this_name|
      if card_references_with_this_name.count == 1 # only 1 by this name, it's either new or deleted
        # if it is a new record, it's newly created, otherwise it's no longer in the text list and needs to be deleted        
        card_references_to_destroy_after_update << card_references_with_this_name.first.id unless card_references_with_this_name.first.new_record? 
      else
        # delete the old ones as the new ones will replace them
        card_references_with_this_name.to_a.each {|a| card_references_to_destroy_after_update << a.id if a.id.present? }
      end      
    end
    Mtg::Decklists::CardReference.where(:id => card_references_to_destroy_after_update).destroy_all    
  end
  
  def generate_mana_string
    self.mana_string = ""
    mana_strings_combined = (self.cards.value_of :mana_string).join
    self.mana_string << '{W}' if mana_strings_combined.include?('{W}')
    self.mana_string << '{U}' if mana_strings_combined.include?('{U}')    
    self.mana_string << '{B}' if mana_strings_combined.include?('{B}')    
    self.mana_string << '{R}' if mana_strings_combined.include?('{R}')    
    self.mana_string << '{G}' if mana_strings_combined.include?('{G}')    
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
    self.get_cards(:subsection => 'Other Spells').count
  end  
  
  def cards_count_creatures
    self.get_cards(:subsection => 'Creatures').count
  end  
  
  def cards_count_sideboard
    self.get_cards(:section => 'Sideboard').count
  end  
  
  def get_relevant_error_message
    if self.errors.messages[:name].present?
      self.errors.messages[:name].first
    elsif self.errors.messages[:card_references].present? && self.errors.messages[:card_references].first.downcase != 'is invalid'
      self.errors.messages[:card_references].first    
    elsif self.errors.messages[:"card_references.card_name"].present?
      self.errors.messages[:"card_references.card_name"].first
    else
      self.errors.messages  
    end
  end
  
  def export_format(options)
    options = {:section => 'all', :subsection => nil}.merge(options)
    output  = ""
    case options[:section]
      when /main deck/i
        self.card_references.select([:quantity, :card_name]).main_deck.each { |card_reference| output << "#{card_reference.quantity} #{card_reference.card_name}\r\n" }
      when /sideboard/i
        self.card_references.select([:quantity, :card_name]).sideboard.each { |card_reference| output << "#{card_reference.quantity} #{card_reference.card_name}\r\n" }        
      else
        self.card_references.select([:quantity, :card_name]).each { |card_reference| output << "#{card_reference.quantity} #{card_reference.card_name}\r\n" }                
    end
    output
  end
  # ----- Class Methods    ----- #  
  
end