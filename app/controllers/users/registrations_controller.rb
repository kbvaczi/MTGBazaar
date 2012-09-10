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
    EmailQueue.push(:template => "account_update_notification", :data => resource)
    super
  end
  
  def create
    super
  end
  
  protected
  
  
end
