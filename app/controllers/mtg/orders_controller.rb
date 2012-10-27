class Mtg::OrdersController < ApplicationController
  
  def checkout
    order = current_cart.orders.includes(:reservations).where(:id => params[:id]).first
    
    order.setup_transaction_for_checkout                                                                          # saves transaction, items, and payment
    
    @gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(                                                 # setup gateway, login to Paypal API
      :pem =>       PAYPAL_CONFIG[:paypal_cert_pem],
      :login =>     PAYPAL_CONFIG[:api_login],
      :password =>  PAYPAL_CONFIG[:api_password],
      :signature => PAYPAL_CONFIG[:api_signature],
      :appid =>     PAYPAL_CONFIG[:appid] )
    
    recipients = [ {:email        => order.seller.account.paypal_username,                                               # setup recipients            
                    :payment_type => "GOODS",                                                                     # tell paypal this payment is for non-digital goods 
                    :primary      => true,                                                                             # seller is primary receiver
                    :amount       => order.total_cost },                                                                # all the money goes through primary
                   {:email        => PAYPAL_CONFIG[:account_email],                                        
                    :payment_type => "SERVICE",                                                                   # second leg of the payment is for service
                    :primary      => false,                                                
                    :amount       => order.transaction.payment.commission + order.transaction.payment.shipping_cost } ] # we get commission + shipping on back end
    
    encoded_secret = Base64.encode64(order.transaction.payment.calculate_secret).encode('utf-8')               # encryptor uses ascii-8bit encoding, we need to convert to utf-8 to put in parameter... see http://stackoverflow.com/questions/11042657/how-to-encrypt-data-in-a-utf-8-string-using-opensslcipher
    
    @purchase = @gateway.setup_purchase(
      :action_type          => "PAY",
      :return_url           => order_checkout_success_url(:secret => encoded_secret),
      :cancel_url           => order_checkout_failure_url,
      :ipn_notification_url => payment_notification_url(:id => order.transaction.id,                            # allows us to checkout the transaction using IPN
                                                        :secret => encoded_secret,                              # for security, so people can't approve transactions on the back-end without paying
                                                        :cart_id => current_cart.id),                           # so we can clear the cart from IPN in case user doesn't clear it on checkout_success_path (scenario where user closes browser or changes url before closing paypal light box)
      :memo                 => "Purchase of #{order.item_count} item(s) from user #{order.seller.username} on MTGBazaar.com",
      :receiver_list        => recipients,
      :fees_payer           => "PRIMARYRECEIVER" )

    Rails.logger.debug "GATEWAY: #{@gateway.debug.inspect}"  rescue ""
    Rails.logger.debug "PURCHASE: #{@purchase.inspect}" rescue ""
    
    order.transaction.payment.paypal_paykey            = @purchase["payKey"]
    order.transaction.payment.paypal_purchase_response = @purchase.inspect 
    order.transaction.payment.save!

    respond_to do |format|
      format.html do
        #TODO: find some way to send mobile payments here
        redirect_to @gateway.embedded_flow_url_for(@purchase["payKey"])
        #redirect_to @gateway.redirect_url_for(@purchase["payKey"])
      end
      format.js {}
    end
  end
  
  def checkout_success
    order = current_cart.orders.includes(:reservations, :transaction => :payment).where(:id => params[:id]).first
    if order.present? # has payment notification already checked out the order?
      decoded_secret = Base64.decode64(params[:secret]).encode('ascii-8bit').decrypt(:key => order.transaction.payment.calculate_key) rescue nil
      if decoded_secret == PAYPAL_CONFIG[:secret]
        order.checkout_transaction
      end
    end
    current_cart.update_cache       # update the shopping cart
    cookies[:checkout] = "success"  # when show cart page is displayed it will have a success message
    render :layout => false         # this will just load javascript that will reload the current page (show cart) to get rid of the light box
  end
  
  def checkout_failure
    cookies[:checkout] = "failure"  # when show cart page is displayed it will have a failure message
    render :layout => false         # this will just load javascript that will reload the current page (show cart) to get rid of the light box
  end
  
end