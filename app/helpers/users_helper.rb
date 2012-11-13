module UsersHelper
  
  def users_list
    Rails.cache.fetch 'users_list' do
      User.pluck(:username).sort rescue []
    end
  end

end
