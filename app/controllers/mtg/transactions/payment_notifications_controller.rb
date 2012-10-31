class Mtg::Transactions::PaymentNotificationsController < ApplicationController  
  protect_from_forgery :except => [:payment_notification]
  skip_before_filter :production_authenticate, :only => [:payment_notification]
  
  def payment_notification
    transaction = Mtg::Transaction.find(params[:id])
    decoded_secret = Base64.decode64(params[:secret]).encode('ascii-8bit').decrypt(:key => transaction.payment.calculate_key)
    if decoded_secret == PAYPAL_CONFIG[:secret] # verify our secret which changes with every payment
      transaction.payment.payment_notifications.create(:response => params, 
                                                       :status => params['status'].downcase, 
                                                       :paypal_transaction_id => params[:transaction]['0']['.id'] )
      if params['transaction_type'] == "Adaptive Payment PAY" # only do this stuff if this is a purchase, not a refund
        transaction.transaction_number = params[:transaction]['0']['.id']                 # this has already been done in the database, but we're setting it to our transaction variable just so we don't have to reload the transaction from the database again        
        transaction.buyer.statistics.update_buyer_statistics!                             # add a purchase to user statistics      
        Cart.find(params[:cart_id]).update_cache if params[:cart_id].present? rescue nil  # update cart in case user doesn't visit checkout_success_path (i.e. user closes browser or changes pages prior to closing paypal lightbox)      
        ApplicationMailer.seller_sale_notification(transaction).deliver                   # send sale notification email to seller
        ApplicationMailer.buyer_checkout_confirmation(transaction).deliver                # send sale notification email to buyer      
      end
    else
      # this will send someone to the "page not found" error page if they dont have the right secret... making it look like this page doesn't exist
      raise ActionController::RoutingError.new('Not Found')
    end
    render :nothing => true
  end
  
end

