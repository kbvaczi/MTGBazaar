class Mtg::Cards::Statistics < ActiveRecord::Base
  
  # --------------------------------------- #
  # ------------ Configuration ------------ #
  # --------------------------------------- #

  self.table_name = 'mtg_card_statistics'  

  # Implement Money gem for price_min column
  composed_of   :price_min,
                :class_name => 'Money',
                :mapping => %w(price_min cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }

  # Implement Money gem for price_low column
  composed_of   :price_low,
                :class_name => 'Money',
                :mapping => %w(price_low cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }

  # Implement Money gem for price_med column
  composed_of   :price_med,
                :class_name => 'Money',
                :mapping => %w(price_med cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }

  # Implement Money gem for price_high column
  composed_of   :price_high,
                :class_name => 'Money',
                :mapping => %w(price_high cents),
                :constructor => Proc.new { |cents| Money.new(cents || 0) },                
                :converter => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : Money.empty }

  # --------------------------------------- #
  # ------------ Database Relationships --- #
  # --------------------------------------- #

  belongs_to :card,     :class_name => "Mtg::Card"
  has_many :listings,   :class_name => "Mtg::Cards::Listing", :through => :card

  # --------------------------------------- #
  # ------------ Validations -------------- #
  # --------------------------------------- #

  #validates_presence_of :number_sales_rejected, :number_sales, :number_sales_cancelled, :positive_feedback_count, :neutral_feedback_count,
  #                      :negative_feedback_count

  #validates :number_sales_rejected, :number_sales, :number_sales_cancelled, :positive_feedback_count, :neutral_feedback_count, :negative_feedback_count,
  #          :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1000000}

  # --------------------------------------- #
  # ------------ Callbacks ---------------- #
  # --------------------------------------- #

  before_save :set_default_card_pricing_if_no_pricing, :on => :create
  
  def set_default_card_pricing_if_no_pricing
    self.price_low = 0.50 if self.price_low == 0
    self.price_med = 1.00 if self.price_med == 0
    self.price_high = 1.50 if self.price_high == 0    
  end

  # --------------------------------------- #
  # ------------ Accessors ---------------- #
  # --------------------------------------- #

  def price_min(overwrite = false)
    if read_attribute(:price_min) && (not overwrite)
      Money.new(read_attribute(:price_min))
    else
      write_attribute(:price_min, (listings.available.minimum(:price) || 0))
      self.save
      Money.new(read_attribute(:price_min) || 0)
    end
  end
  
  def listings_available(overwrite = false)
    if read_attribute(:listings_available) && (not overwrite)
      read_attribute(:listings_available)       
    else
      write_attribute(:listings_available, (listings.available.sum(:quantity_available) || 0))
      self.save
      read_attribute(:listings_available || 0)
    end
  end  

  # --------------------------------------- #
  # ------------ Public Model Methods ----- #
  # --------------------------------------- #


  def update!
    #gather all sales of this card
    sales = Mtg::Transactions::Item.includes(:transaction).where(:card_id => self.card_id).where("mtg_transactions.status LIKE ?", "delivered").order("created_at DESC")
    self.number_sales = sales.count
    #get the latest 20 "normal" completed sales to compute pricing
    latest_sold_items = sales.where(:foil => false, :altart => false, :misprint => false, :signed => false).limit(20)
    if latest_sold_items.present?
      min = latest_sold_items.minimum("price").to_f / 100
      avg = latest_sold_items.average("price").to_f / 100
      max = latest_sold_items.maximum("price").to_f / 100
      if min == avg 
        self.price_low = (0.8 * avg).to_money
      else
        self.price_low = ( (min + min + avg) / 3 ).to_money
      end
      self.price_med = avg.to_money
      if min == avg 
        self.price_high = (1.2 * avg).to_money
      else
        self.price_high = ( (max + max + avg) / 3 ).to_money
      end 
    end
    self.save
  end

end
