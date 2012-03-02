class Users::DepositsController < InheritedResources::Base

  before_filter :authenticate_user!
  def new
    @deposit = Users::Deposit.new
    session[:return_to] = request.referer
  end
  
  def create
    if params[:users_deposit].has_key?("current_password")
      if current_user.valid_password?(params[:users_deposit][:current_password])
        @deposit = Users::Deposit.new(params[:users_deposit])
        if @deposit.save
          @deposit.update_attribute(:current_sign_in_ip, request.remote_ip) #log depositor's IP address
          current_user.account.deposits << @deposit #link this deposit to current user's account
          current_user.account.update_attribute(:balance, current_user.account.balance + @deposit.balance) #add deposit to user's balance
          redirect_to session[:return_to] || :back, :notice => "Deposit Sucessful..."
        else
          flash[:error] = "#{@deposit.errors.full_messages}"
          redirect_to new_users_deposit_path
        end
      else
        flash[:error] = "Password does not match..."
        redirect_to new_users_deposit_path
      end
    end
  end
  


end
