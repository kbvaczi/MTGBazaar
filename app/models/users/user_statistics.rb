class UserStatistics < ActiveRecord::Base
  
  # ------------ Configuration ------------ #

  self.table_name = 'user_statistics'  
  serialize :ip_log
  
  # ------------ Callbacks ---------------- #
  
  
  # ------------ Database Relationships --- #

  belongs_to :user

  # ------------ Validations -------------- #

  validates_presence_of     :number_sales, :number_sales_cancelled, :positive_feedback_count, :neutral_feedback_count,
                            :negative_feedback_count
  
  validates :number_sales, :positive_feedback_count, :neutral_feedback_count, :negative_feedback_count,
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1000000}
  
  # ------------ Model Methods ------------ #
  
  def update_seller_statistics!
    self.number_sales               = self.user.mtg_sales.count

    sales_with_feedback             = self.user.mtg_sales.includes(:feedback).with_feedback        
    self.number_sales_with_feedback = sales_with_feedback.to_a.length
    self.positive_feedback_count    = sales_with_feedback.where("mtg_transactions_feedback.rating = ?", "1").count
    self.neutral_feedback_count     = sales_with_feedback.where("mtg_transactions_feedback.rating = ?", "0").count
    self.negative_feedback_count    = self.number_sales_with_feedback - self.positive_feedback_count - self.neutral_feedback_count
    percent                         = ( ( ( self.positive_feedback_count + self.neutral_feedback_count ).to_f / self.number_sales_with_feedback ) * 100 ) rescue 0
    self.approval_percent           = percent.nan? ? 0 : percent # handle divide by 0 error

    shipped_sales                   = self.user.mtg_sales.shipped
    self.average_ship_time          = ( ( shipped_sales.sum(&:seller_shipped_at) - shipped_sales.sum(&:created_at) ) / 1.day / shipped_sales.count ).round(2) rescue 0
    
    self.save
  end
  
  def update_buyer_statistics!
    self.number_purchases = self.user.mtg_purchases.count
    self.save
  end
  
  def update_number_strikes!
    self.number_strikes = self.user.tickets_about.where(:strike => true).count
    self.save
  end
  
  def update_listings_mtg_cards_count
    self.update_attribute(:listings_mtg_cards_count, Mtg::Cards::Listing.available.where(:seller_id => self.user_id).sum(:quantity_available))
  end

  def display_approval_percent
    if (self.number_sales_with_feedback > 0 rescue false)
      "#{self.approval_percent.round(0)}%" rescue "0%"
    else
      "none"
    end
  end
  
  #TODO: display_average_confirm_time is no longer relevant
  def display_average_confirm_time
    if self.average_confirm_time.present?
      self.average_confirm_time.to_s + " days"
    else
      "No Sales Yet"
    end
  end
  
  def display_average_ship_time
    if self.average_ship_time.present?
      self.average_ship_time.to_s + " days"
    else
      "No Sales Yet"
    end
  end
  
  def update_ip_log(current_ip)
    Rails.logger.debug "CALLING USER_STATISTICS.update_ip_log"
    if current_ip.present?
      current_ip_log = self.ip_log || Array.new
      geocoded_info  = Geocoder.search(current_ip)[0] rescue false
      self.ip_log    = current_ip_log.push( { :time =>    Time.now.in_time_zone("Central Time (US & Canada)"), 
                                              :ip =>      current_ip, 
                                              :city =>    (geocoded_info.city    rescue ""),
                                              :state =>   (geocoded_info.state   rescue ""),
                                              :country => (geocoded_info.country rescue "") } ).last(20)
      self.save
    end
  end
  
end