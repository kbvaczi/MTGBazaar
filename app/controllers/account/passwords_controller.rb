class Account::PasswordsController < Devise::PasswordsController
  skip_before_filter :require_no_authentication, :only => [:new]

  #sign out the user if they request to change their password
  def new
    sign_out(resource)
    super
  end  
  
end  