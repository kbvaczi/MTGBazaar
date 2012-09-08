class Users::RegistrationsController < Devise::RegistrationsController

  def new
    @user = resource
    super
  end
  
  def edit
    @user = resource
    super      
  end
  
  def update
    ApplicationMailer.account_update_notification(resource).deliver
    super
  end
  
  def create
    super
  end
  
  protected
  
  
end
