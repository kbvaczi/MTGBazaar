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
      write_attribute(:listings_available, (Mtg::Cards::Listing.where(:card_id => self.card_id).select([:seller_id, :quantity_available, :number_cards_per_item]).available.to_a.inject(0) {|sum, listing| sum + listing.quantity_available * listing.number_cards_per_item} || 0))
      self.save
      read_attribute(:listings_available || 0)
    end
  end  

  # --------------------------------------- #
  # ------------ Public Model Methods ----- #
  # --------------------------------------- #


  def update!        
    #gather all sales of this card
    self.number_sales = Mtg::Transactions::Item.where(:card_id => self.card_id).count
    self.save
  end
  
  def update_pricing    
    #get the latest "normal" completed sales to compute pricing
    selection_size = 21
    latest_sold_items_pricing = Mtg::Transactions::Item.where(:card_id => self.card_id).where(:foil => false, :altart => false, :misprint => false, :signed => false).order("created_at DESC").limit(selection_size).pluck(:price).sort!
    latest_sold_items_count   = latest_sold_items_pricing.length rescue 0
    Rails.logger.debug "listing price array = #{latest_sold_items_pricing}"

    if latest_sold_items_count > 0 # there are sales, let's recalculate pricing
      low_third_pricing  = latest_sold_items_pricing[0..(latest_sold_items_count / 3).ceil]
      med_third_pricing  = latest_sold_items_pricing[(latest_sold_items_count / 3)..((latest_sold_items_count / 3) * 2).ceil]
      high_third_pricing = latest_sold_items_pricing[((latest_sold_items_count / 3) * 2)...latest_sold_items_count]
      
      Rails.logger.debug "low price array  = #{low_third_pricing}"
      Rails.logger.debug "med price array  = #{med_third_pricing}"      
      Rails.logger.debug "high price array = #{high_third_pricing}"            
      low_third_average  = Money.new(low_third_pricing.inject(0.0)  {|sum, price| sum + price } / low_third_pricing.length)
      med_third_average  = Money.new(med_third_pricing.inject(0.0)  {|sum, price| sum + price } / med_third_pricing.length)
      high_third_average = Money.new(high_third_pricing.inject(0.0) {|sum, price| sum + price } / high_third_pricing.length)
      
      Rails.logger.debug "low price average  = #{low_third_average}"
      Rails.logger.debug "med price average  = #{med_third_average}"      
      Rails.logger.debug "high price average = #{high_third_average}"
      if latest_sold_items_count < selection_size # not enough sales for valid data, weight recent sales against prevous data
        weight_factor_for_sales = latest_sold_items_count.to_f / selection_size.to_f
        Rails.logger.debug "weight_factor = #{weight_factor_for_sales}"

        self.price_low  = (low_third_average  * weight_factor_for_sales + self.price_low  * (1-weight_factor_for_sales))
        self.price_med  = (med_third_average  * weight_factor_for_sales + self.price_med  * (1-weight_factor_for_sales))
        self.price_high = (high_third_average * weight_factor_for_sales + self.price_high * (1-weight_factor_for_sales))
      else # there are enough recent sales for valid data
        self.price_low  = low_third_average
        self.price_med  = med_third_average
        self.price_high = high_third_average
      end
      Rails.logger.debug "final low     = #{self.price_low}"
      Rails.logger.debug "final average = #{self.price_med}"      
      Rails.logger.debug "final high    = #{self.price_high}"
    end    
    
  end
  
  def self.bulk_update_listing_information(card_ids_array)
    card_ids_array_sql = card_ids_array.to_s.gsub('[','(').gsub(']',')')
    query = %{  UPDATE  mtg_card_statistics
                  JOIN  ( SELECT    mtg_listings.card_id,
                                    MIN(mtg_listings.price) AS aggregate_price_min,
                                    SUM(mtg_listings.quantity_available) AS aggregate_listings_available
                          FROM      mtg_listings
                          GROUP BY  mtg_listings.card_id
                          HAVING    mtg_listings.card_id IN #{card_ids_array_sql} ) aggregate_listing_data
                    ON  aggregate_listing_data.card_id = mtg_card_statistics.card_id
                   SET  mtg_card_statistics.price_min = aggregate_listing_data.aggregate_price_min,
                        mtg_card_statistics.listings_available = aggregate_listing_data.aggregate_listings_available
                 WHERE  mtg_card_statistics.card_id IN #{card_ids_array_sql};  }
    ActiveRecord::Base.connection.execute(query);
    
  end
  
  def self.bulk_update_sales_information(card_ids_array)
    card_ids_array_sql = card_ids_array.to_s.gsub('[','(').gsub(']',')')
    query = %{  UPDATE  mtg_card_statistics
                  JOIN  ( SELECT    mtg_transaction_items.card_id,
                                    SUM(quantity_available) AS aggregate_number_sales
                          FROM      mtg_transaction_items
                          JOIN      mtg_transactions
                          ON        mtg_transactions.id = mtg_transaction_items.transaction_id AND (mtg_transactions.status = 'complete' OR mtg_transactions.status = 'confirmed')
                          GROUP BY  mtg_transaction_items.card_id
                          HAVING    mtg_transaction_items.card_id IN #{card_ids_array_sql} ) aggregate_data
                    ON  aggregate_data.card_id = mtg_card_statistics.card_id
                   SET  mtg_card_statistics.number_sales = aggregate_data.aggregate_number_sales
                 WHERE  mtg_card_statistics.card_id IN #{card_ids_array_sql};  }                 
    ActiveRecord::Base.connection.execute(query);    
    
  end  

end
