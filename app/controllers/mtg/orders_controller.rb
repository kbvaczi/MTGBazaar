class Mtg::OrdersController < ApplicationController
  
  def checkout
    order = current_cart.orders.includes(:reservations).where(:id => params[:id]).first
    
    order.setup_transaction_for_checkout                                                                          # saves transaction, items, and payment
    
    gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(                                                 # setup gateway, login to Paypal API
      :pem =>       PAYPAL_CONFIG[:paypal_cert_pem],
      :login =>     PAYPAL_CONFIG[:api_login],
      :password =>  PAYPAL_CONFIG[:api_password],
      :signature => PAYPAL_CONFIG[:api_signature],
      :appid =>     PAYPAL_CONFIG[:appid] )
    
    recipients = [ {:email => order.seller.account.paypal_username,                                               # setup recipients            
                    :primary => true,                                                                             # seller is primary receiver
                    :amount => order.total_cost },                                                                # all the money goes through primary
                   {:email => PAYPAL_CONFIG[:account_email],                                        
                    :primary => false,                                                
                    :amount => order.transaction.payment.commission + order.transaction.payment.shipping_cost } ] # we get commission + shipping on back end
    
    encoded_secret = Base64.encode64(order.transaction.payment.calculate_secret).encode('utf-8')               # encryptor uses ascii-8bit encoding, we need to convert to utf-8 to put in parameter... see http://stackoverflow.com/questions/11042657/how-to-encrypt-data-in-a-utf-8-string-using-opensslcipher
    
    purchase = gateway.setup_purchase(
      :action_type          => "PAY",
      #TODO: return_url can't display secret code
      :return_url           => order_checkout_success_url(:secret => encoded_secret),
      :cancel_url           => order_checkout_failure_url,
      :ipn_notification_url => payment_notification_url(:id => order.transaction.id, :secret => encoded_secret),       
      :memo                 => "TEST",
      :receiver_list        => recipients,
      :fees_payer           => "PRIMARYRECEIVER" )
    
    order.transaction.payment.paypal_paykey            = purchase["payKey"]
    order.transaction.payment.paypal_purchase_response = purchase.inspect 
    order.transaction.payment.save!
    
    Rails.logger.info "GATEWAY: #{gateway.debug.inspect}"  rescue ""
    Rails.logger.info "PURCHASE: #{purchase.inspect}" rescue ""
    
    #redirect_to "https://www.sandbox.paypal.com/webscr?cmd=_ap-payment&paykey=#{order.transaction.payment.paypal_paykey}"    
    #redirect_to gateway.embedded_flow_url_for(purchase["payKey"])
    redirect_to gateway.redirect_url_for(purchase["payKey"])
  end
  
  def checkout_success
    order = current_cart.orders.includes(:reservations).where(:id => params[:id]).first
    if order.present? # has payment notification already checked out the order?
      decoded_secret = Base64.decode64(params[:secret]).encode('ascii-8bit').decrypt(:key => order.transaction.payment.calculate_key)
      if decoded_secret != PAYPAL_CONFIG[:secret]
        flash[:error] = "There was a problem with your request..."
        redirect_to show_cart_path
        return
      end
      order.checkout_transaction
      #ApplicationMailer.seller_sale_notification(transaction).deliver # send sale notification email to seller
      #ApplicationMailer.buyer_checkout_confirmation(transaction).deliver # send sale notification email to seller        
      current_cart.update_cache # empty the shopping cart
    end
    redirect_to show_cart_path, :notice => "Your purchase request has been submitted."  
    return # stop method, don't display a view
  end
  
  def checkout_failure
    flash[:error] = "Your purchase request was cancelled..."
    redirect_to show_cart_path    
  end
  
end