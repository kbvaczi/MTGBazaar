class Users::RegistrationsController < Devise::RegistrationsController

  def new


    super
      @user = resource.with_account

  end
  
  def edit

    super
      @user = resource
      @account = @user.account
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
