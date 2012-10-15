class Mtg::Transactions::PaymentNotificationsController < ApplicationController  
  protect_from_forgery :except => [:payment_notification]
  skip_before_filter :production_authenticate, :only => [:payment_notification]
  
  def payment_notification
    if params[:key] == PAYPAL_CONFIG[:secret]
      transaction = Mtg::Transaction.find(params[:id])
      transaction.payment.payment_notification = Mtg::Transactions::PaymentNotification.create!(:response => params, 
                                                                                                :status => params['status'].downcase, 
                                                                                                :paypal_transaction_id => params[:transaction]['0']['.id'] )
      if params['status'] == "COMPLETED"                              # check to see if payment was successful
        transaction.payment.update_attributes(:status => "completed", :paypal_transaction_number => params[:transaction]['0']['.id'])
        transaction.order.checkout_transaction if transaction.order.present?
        transaction.update_attribute(:transaction_number, params[:transaction]['0']['.id'])
      end
    end
    
    render :nothing => true    
  end
  
end