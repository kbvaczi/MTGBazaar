class ApplicationController < ActionController::Base
  protect_from_forgery
  #helper :all

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
    if current_user.present? or verify_recaptcha or session[:captcha] == true
      session[:captcha] = true if not session[:captcha]
      return true
    else
      return false
    end
  end

  # returns the current users's cart model 
  def current_cart
    if session[:cart_id] # current session already has a cart, let's link to it
      @current_cart ||= Cart.find(session[:cart_id]) 
      @current_cart.update_attribute(:user_id, current_user.id) if current_user # assign user to cart when they log in
    elsif session[:cart_id].nil? # there is no cart for current session, let's create one
      @current_cart ||= Cart.create! # create a cart if there isn't one already
      session[:cart_id] = @current_cart.id # link cart to current session
    end
    @current_cart
  end
  helper_method :current_cart
  
  def set_back_path
    session[:return_to] = request.fullpath
  end
  
  # returns to the url where set_back_path has last been set and clears back_path
  def back_path
    return_path = session[:return_to] || root_path
    session[:return_to] = nil
    return return_path
  end
  
  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
  end
    
end
