module UsersHelper
  
  def users_list
    Rails.cache.fetch 'users_list', :expires_in => 1.days do
      User.pluck(:username).sort rescue []
    end
  end
  
  def top_sellers_list
    Rails.cache.fetch 'top_sellers_list', :expires_in => 1.days do
      User.active.joins(:statistics).where("user_statistics.approval_percent > \'60.0\'").order("user_statistics.number_sales DESC").limit(10).values_of :username, :id
    end
  end  

end
