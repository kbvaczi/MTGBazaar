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

    if verify_humanity #verify_recaptcha

      super

      
    else

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
