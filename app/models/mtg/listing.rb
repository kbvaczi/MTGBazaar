class Mtg::Listing < ActiveRecord::Base
  self.table_name = 'mtg_listings'    
  
  belongs_to :card, :class_name => "Mtg::Card"
  belongs_to :seller, :class_name => "User"  
  
  # Implement Money gem foro price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :set, :quantity, :price, :condition, :language, :description, :foreign, :defect, :foil

  # not-in-model field for current password confirmation
  attr_accessor :name, :set, :quantity

end
