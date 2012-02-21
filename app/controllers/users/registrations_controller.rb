class Users::RegistrationsController < Devise::RegistrationsController

  def new
    @user = resource
    @age_checked = true
    super
  end
  
  def edit
    @user = resource
    super      
  end
  
  def create
    if check_humanity
      super
    else
      build_resource
      clean_up_passwords(resource)
      flash[:error] = "Please re-enter captcha code. Thanks for helping us prevent spam!"
      render :new
    end
  end
  
  protected
  
  def check_humanity
    if verify_recaptcha or session[:captcha] == true
      session[:captcha] = true if not session[:captcha]
      return true
    else
      return false
    end
    
  end
  
end
