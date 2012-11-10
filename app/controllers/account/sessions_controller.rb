class Account::SessionsController < Devise::SessionsController

protected

  # do this after a user signs in
  def after_sign_in_path_for(resource) 
    if resource.is_a?(User)
      if resource.banned?
        sign_out resource
        flash[:error]  = "This account has been suspended..."
        flash[:notice] = nil # erase any notice so that error can be displayed
        root_path
      else
        flash[:notice] = "Welcome back #{resource.username}"
        resource.statistics.update_ip_log(resource.current_sign_in_ip) if resource.updated_at > 5.minutes.ago # update IP Log
        back_path         
      end
    else
      super
    end
  end
  
  # devise redirect after sign out
  def after_sign_out_path_for(resource)
    if current_cart.present? 
      current_cart.empty # empty cart
      current_cart.destroy # kill this user's cart
    end
    super
  end
  
end