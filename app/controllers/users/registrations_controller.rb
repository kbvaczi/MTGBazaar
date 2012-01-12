class Users::RegistrationsController < Devise::RegistrationsController

  def new


    super
      @user = resource
      @account = Account.new
      @user.account = @account
  end
  
  def edit

    super
      resource.build_account(params[:account])
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
