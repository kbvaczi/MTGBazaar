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

    self.number_sales = sales.where(:status => "delivered").count
    self.number_sales_rejected = sales.where(:status => "rejected").count
    self.number_sales_cancelled = sales.where(:status => "cancelled").count    
    self.positive_feedback_count = sales.where(:buyer_feedback => 1).count
    self.neutral_feedback_count = sales.where(:buyer_feedback => 0).count    
    self.negative_feedback_count = sales.where(:buyer_feedback => -1).count        

    delivered_sales = sales.where(:status => "delivered")
    self.average_confirm_time = ( delivered_sales.sum(:seller_confirmed_at) - delivered_sales.sum(:created_at) ) / delivered_sales.count
    self.average_ship_time = ( delivered_sales.sum(:seller_shipped_at) - delivered_sales.sum(:created_at) ) / delivered_sales.count    
  end
  
  def update_buyer_statistics!
    self.number_sales = self.user.mtg_purchases.where(:status => "delivered").count
  end
  
  def update_number_strikes!
    
  end
  
end