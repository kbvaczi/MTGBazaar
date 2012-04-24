class Mtg::TransactionItem < ActiveRecord::Base
  self.table_name = 'mtg_transaction_items'    
  
  belongs_to :card,         :class_name => "Mtg::Card"
  belongs_to :seller,       :class_name => "User"
  belongs_to :buyer,        :class_name => "User"  
  belongs_to :transaction,  :class_name => "Mtg::Transaction"
  
  # Implement Money gem for price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :set, :quantity, :price, :condition, :language, :description, :altart, :misprint, :foil, :signed

  # not-in-model field for current password confirmation
  attr_accessor :name, :set
  
  # validations
  validates_presence_of :price, :condition, :language, :quantity

  # mark this listing as rejected which permenantly removes it from user view
  def mark_as_rejected!
    self.update_attribute(:rejected_at, Time.now)
    self.update_attribute(:active, false)    
  end  

  # searches for rejected listings.  Rejected listings are dummy placeholders for tracking rejected transactions... users cannot see rejected listings
  def self.rejected
    where("rejected_at IS NOT NULL")
  end  
  
  # used for searching listings by seller...  Mtg::Listing.by_seller_id([2,3]) will return all listings from seller 2 and 3
  def self.by_seller_id(id)
    where(:seller_id => id )
  end
  
  def self.by_id(id)
    where(:id => id)
  end  
  
  def formatted_condition
    case self.condition
      when /1/ 
        return "NM"
      when /2/ 
        return "EX"
      when /3/ 
        return "FN"
      when /4/ 
        return "GD"
      else return "Unknown"
    end
  end

end