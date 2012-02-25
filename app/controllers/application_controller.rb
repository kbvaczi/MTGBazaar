class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :user_banned?
  before_filter :production_authenticate
  
  protected
  
  #checks to see if the current logged in user is banned.  logs out and flashes warning if so.
  def user_banned?
    if current_user.present? && current_user.banned?
      sign_out current_user
      flash[:error] = "This account has been suspended..."
      root_path
    end
  end
  
  def production_authenticate
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        username == "site" && password == "test"
      end 
    end
  end
  
end
