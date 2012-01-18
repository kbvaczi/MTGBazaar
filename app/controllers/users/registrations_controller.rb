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
      flash[:error] = "We were unable to verify your humanity. Please re-enter captcha code."
      render_with_scope :new
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
