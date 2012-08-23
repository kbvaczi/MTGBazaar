class PaymentNotificationsController < ApplicationController
  protect_from_forgery :except => [:create]
  skip_before_filter :production_authenticate
  
  def create
    PaymentNotification.create!(:params => params, :account_balance_transfer_id => params[:invoice], :status => params[:payment_status], :transaction_id => params[:txn_id] )
    render :nothing => true
  end
  
  def acknowledge_deposit
    redirect_to root_path, :notice => "Your deposit was successful!"
    return
  end
  
end
