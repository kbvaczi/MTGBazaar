class UserStatistics < ActiveRecord::Base
  self.table_name = 'user_statistics'  
  
  # --------------------------------------- #
  # ------------ Database Relationships --- #
  # --------------------------------------- #

  belongs_to :user

  # --------------------------------------- #
  # ------------ Validations -------------- #
  # --------------------------------------- #

  # --------------------------------------- #
  # ------------ Model Methods ------------ #
  # --------------------------------------- #
  
  def update_seller_statistics!
    sales = self.user.mtg_sales

    self.number_sales_rejected = sales.where(:status => "rejected").count
    self.number_sales_cancelled = sales.where(:status => "cancelled").count    
    self.positive_feedback_count = sales.where(:buyer_feedback => "1").count
    self.neutral_feedback_count = sales.where(:buyer_feedback => "0").count    
    self.negative_feedback_count = sales.where(:buyer_feedback => "-1").count        

    delivered_sales = sales.where(:status => "delivered")
    self.number_sales = delivered_sales.count
    self.average_confirm_time = ( ( delivered_sales.sum(&:seller_confirmed_at) - delivered_sales.sum(&:created_at) ) / 1.day / delivered_sales.count ).round(2) rescue 0 # handle divide by 0 error
    self.average_ship_time = ( ( delivered_sales.sum(&:seller_shipped_at) - delivered_sales.sum(&:created_at) ) / 1.day / delivered_sales.count ).round(2) rescue 0 # handle divide by 0 error
    
    self.save
  end
  
  def update_buyer_statistics!
    self.number_purchases = self.user.mtg_purchases.where(:status => "delivered").count
    self.save
  end
  
  def update_number_strikes!
    self.number_strikes = self.user.tickets_about.where(:strike => true).count
    self.save
  end
  
  def display_approval_percent
    ( ( ( self.positive_feedback_count + self.neutral_feedback_count ).to_f / self.number_sales.to_f ) * 100 ).round(0) rescue 0 # handle divide by 0 error
  end
  
end