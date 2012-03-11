class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :all

  before_filter :user_banned?                   # make sure the user is not banned before loading anything
  before_filter :production_authenticate        # simple HTTP authentication for production (TEMPORARY)
  before_filter :current_cart                   # every user gets a cart when they come to the webpage... items added to cart are reserved... carts will expire every 30 minutes and inventory will be returned to the store.

  protected

  # checks to see if the current logged in user is banned.  logs out and flashes warning if so.
  def user_banned?                              
    if current_user.present? && current_user.banned?
      sign_out current_user
      flash[:error] = "This account has been suspended..."
      root_path
    end
  end
  
  # temporary HTTP authentication for production server
  def production_authenticate
    if Rails.env.production?
      authenticate_or_request_with_http_basic do |username, password|
        username == "site" && password == "test"
      end 
    end
  end

  def check_humanity
    if current_user or verify_recaptcha or session[:captcha] == true
      session[:captcha] = true if not session[:captcha]
      return true
    else
      return false
    end
  end

  # returns the current users's cart model 
  def current_cart
    @current_cart ||= Cart.new(session)      
  end
  helper_method :current_cart  
  
  def create_back_path
    session[:return_to] = request.fullpath
  end

  def back_path
    return session[:return_to] || root_path
  end
  
  def help
    Helper.instance
  end

  class Helper

    include Singleton
    include ActionView::Helpers::TextHelper
  end
    
end
