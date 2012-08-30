class Users::RegistrationsController < Devise::RegistrationsController

  def new
    @user = resource
    super
  end
  
  def edit
    @user = resource
    super      
  end
  
  def create
    super

    # No longer using recaptcha
    #if check_humanity
    #  super
    #else
    #  build_resource
    #  clean_up_passwords(resource)
    #  flash[:error] = "Please re-enter captcha code. Thanks for helping us prevent spam!"
    #  render :new
    #end
    
  end
  
  protected
  
  
end
