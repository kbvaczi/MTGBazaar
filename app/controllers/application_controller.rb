class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :banned?
  
  
  protected
  
  #checks to see if the current logged in user is banned.  logs out and flashes warning if so.
  def banned?
    if current_user.present? && current_user.banned?
      sign_out current_user
      flash[:error] = "This account has been suspended..."
      root_path
    end
  end
  
  def require_admin!
    unless current_user.try :is_admin?
      redirect_to root_path, flash[:error] => "Access Denied"
    end
  end
  
end
