class Users::RegistrationsController < Devise::RegistrationsController

  def new


    super
      @user = resource

  end
  
  def edit

    super
      @user = resource

  end
  
  def create

    if verify_recaptcha
      super
    else
      build_resource
      clean_up_passwords(resource)
      flash[:error] = "Please re-enter captcha code. Thanks for helping us prevent spam!"
      render :new
    end
    
  end
  
  def update

    super
  end    
  
  
  protected
  
    def verify_humanity
      return true
    end
  
end
