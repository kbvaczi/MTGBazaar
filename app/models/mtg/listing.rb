class Mtg::Listing < ActiveRecord::Base
  self.table_name = 'mtg_listings'    
  
  belongs_to :card, :class_name => "Mtg::Card"
  belongs_to :seller, :class_name => "User"
  belongs_to :transaction, :class_name => "Mtg::Transaction"
  belongs_to :cart
  
  # Implement Money gem foro price column
  composed_of   :price,
                :class_name => 'Money',
                :mapping => %w(price cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :card_id, :name, :set, :quantity, :price, :condition, :language, :description, :foreign, :defect, :foil

  # not-in-model field for current password confirmation
  attr_accessor :name, :set, :quantity, :price_options
  
  # determins if listing is available to be added to cart (active, not already in cart, and not already sold)
  def available?
    self.reserved == false and self.active == true and self.sold_at == nil
  end
  
  def reserve!
    self.update_attribute(:reserved, true)
  end

  def free!
    self.update_attribute(:reserved, false)
  end  
  
  def self.available
    where(:reserved => false, :active => true, :sold_at => nil)
  end
  


end
