class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  protected
  
  def require_admin!
    unless current_user.try :is_admin?
      redirect_to root_path, flash[:error] => "Access Denied"
    end
  end
  
end
