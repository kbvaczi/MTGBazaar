class Users::SessionsController < Devise::SessionsController

protected

  # do this after a user signs in
  def after_sign_in_path_for(resource) 
    if resource.is_a?(User) && resource.banned?
      sign_out resource
      flash[:error] = "This account has been suspended..."
      flash[:notice] = nil #erase any notice so that error can be displayed
      root_path
    elsif resource.is_a?(User)
      back_path
    else
      super
    end
  end
  
  # devise redirect after sign up
  def after_sign_up_path_for(resource)
    if resource.is_a?(User)
      back_path
    else
      super
    end
  end
  
  # devise redirect after sign out
  def after_sign_out_path_for(resource)
    current_cart.empty! # empty cart
    current_cart.destroy # kill this user's cart
    super
  end
  
end