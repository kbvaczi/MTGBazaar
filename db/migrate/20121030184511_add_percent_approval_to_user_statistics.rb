class AddPercentApprovalToUserStatistics < ActiveRecord::Migration
  def up
    add_column(   :user_statistics,   :approval_percent,            :float,           :default => 0)    unless column_exists?(:user_statistics, :approval_percent)
    add_column(   :user_statistics,   :number_sales_with_feedback,  :integer,         :default => 0)  unless column_exists?(:user_statistics, :number_sales_with_feedback)
        
    remove_column :user_statistics,   :number_sales_rejected                   if     column_exists?(:user_statistics, :number_sales_rejected)
    remove_column :user_statistics,   :average_confirm_time                    if     column_exists?(:user_statistics, :average_confirm_time )    

    add_index     :user_statistics,             :approval_percent              unless index_exists?(:user_statistics, :approval_percent)
    add_index     :user_statistics,             :number_sales                  unless index_exists?(:user_statistics, :number_sales)
    add_index     :mtg_transactions_feedback,   :rating                        unless index_exists?(:mtg_transactions_feedback, :rating)
  end
  
  def down
    add_column(   :user_statistics,   :number_sales_rejected,   :float)    unless column_exists?(:user_statistics, :number_sales_rejected)
    add_column(   :user_statistics,   :average_confirm_time,    :integer)  unless column_exists?(:user_statistics, :average_confirm_time)
  end
  
end
