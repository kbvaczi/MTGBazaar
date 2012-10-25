class UserStatistics < ActiveRecord::Base
  
  # ------------ Configuration ------------ #

  self.table_name = 'user_statistics'  
  serialize :ip_log  
  
  # ------------ Callbacks ---------------- #
  
  before_create :set_ip_log
  
  # text types cannot have default values in mysql so we must manually set ip_log before creation
  def set_ip_log
    self.ip_log = "[]"
  end
  
  # ------------ Database Relationships --- #

  belongs_to :user

  # ------------ Validations -------------- #

  validates_presence_of :number_sales_rejected, :number_sales, :number_sales_cancelled, :positive_feedback_count, :neutral_feedback_count,
                        :negative_feedback_count
  
  validates :number_sales, :positive_feedback_count, :neutral_feedback_count, :negative_feedback_count,
            :numericality => {:only_integer => true, :greater_than_or_equal_to => 0, :less_than => 1000000}
  
  # ------------ Model Methods ------------ #
  
  def update_seller_statistics!
    completed_sales               = self.user.mtg_sales.includes(:feedback).with_feedback
    self.number_sales             = completed_sales.count
    self.positive_feedback_count  = completed_sales.where("mtg_transactions_feedback.rating = ?", "1").count
    self.neutral_feedback_count   = completed_sales.where("mtg_transactions_feedback.rating = ?", "0").count
    self.negative_feedback_count  = self.number_sales - self.positive_feedback_count - self.negative_feedback_count
    self.average_ship_time        = ( ( completed_sales.sum(&:seller_shipped_at) - completed_sales.sum(&:created_at) ) / 1.day / completed_sales.count ).round(2) rescue 0 # handle divide by 0 error
    self.save
  end
  
  def update_buyer_statistics!
    self.number_purchases = self.user.mtg_purchases.where(:status => "completed").count
    self.save
  end
  
  def update_number_strikes!
    self.number_strikes = self.user.tickets_about.where(:strike => true).count
    self.save
  end
  
  def approval_percent
    ( ( ( self.positive_feedback_count + self.neutral_feedback_count ).to_f / self.number_sales.to_f ) * 100 ) rescue 0 # handle divide by 0 error
  end
  
  def display_approval_percent
    if self.number_sales > 0
      "#{self.approval_percent.round(0)}%" 
    else
      "0%"
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
  
end