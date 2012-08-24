class PaymentNotificationsController < ApplicationController
  protect_from_forgery :except => [:create_deposit_notification, :create_withdraw_notification]
  skip_before_filter :production_authenticate
  
  def create_deposit_notification
    PaymentNotification.create!(:params => params, :account_balance_transfer_id => params[:invoice], :status => params[:payment_status], :transaction_id => params[:txn_id] )
    render :nothing => true
  end
  
  def acknowledge_deposit
    redirect_to root_path, :notice => "Your deposit was successful!"
    return
  end
  
  def create_withdraw_notification
    PaymentNotification.create!(:params => params, :account_balance_transfer_id => params[:transaction]['0']['.invoiceId'], :status => params[:transaction]['0']['.status'], :transaction_id => params[:transaction]['0']['.id_for_sender_txn'] )
    render :nothing => true
  end
  
end
