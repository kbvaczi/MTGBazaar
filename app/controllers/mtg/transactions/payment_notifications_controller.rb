class Mtg::Transactions::PaymentNotificationsController < ApplicationController  
  protect_from_forgery :except => [:payment_notification]
  skip_before_filter :production_authenticate, :only => [:payment_notification]
  
  def payment_notification
    transaction = Mtg::Transaction.find(params[:id])
    if params[:secret].decrypt(:key => transaction.payment.calculate_key) == PAYPAL_CONFIG[:secret] # verify our secret which changes with every payment
      transaction.payment.payment_notifications.create(:response => params, 
                                                       :status => params['status'].downcase, 
                                                       :paypal_transaction_id => params[:transaction]['0']['.id'] )
    else
      raise ActionController::RoutingError.new('Not Found')
    end
    render :nothing => true
  end
  
end