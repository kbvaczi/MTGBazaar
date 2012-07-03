class CreateUserStatistics < ActiveRecord::Migration

  def up
    create_table :user_statistics do |t|
      # foreign keys
      t.integer   :user_id

      # class variables  
      t.integer   :number_purchases,          :default => 0

      t.integer   :number_sales,              :default => 0
      t.integer   :number_sales_rejected,     :default => 0
      t.integer   :number_sales_cancelled,    :default => 0
      t.float     :average_confirm_time,      :default => nil      # number in days
      t.float     :average_ship_time,         :default => nil      # number in days
      t.integer   :positive_feedback_count,   :default => 0
      t.integer   :negative_feedback_count,   :default => 0      
      t.integer   :neutral_feedback_count,    :default => 0            
      
      t.text      :ip_log,                    :default => "[]"        # list of previous login IPs      
      t.integer   :number_strikes,            :default => 0
      
      t.timestamps
    end

    # Table Indexes
    add_index :user_statistics, :user_id
    
    User.all.each do |user|
      user.statistics = UserStatistics.create
    end
  end

  def down
    drop_table :user_statistics
  end
end
