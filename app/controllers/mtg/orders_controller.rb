class Mtg::OrdersController < ApplicationController
  
  before_filter :verify_minimum_order_amount, :only => [:checkout]
  
  def checkout
    @order ||= current_cart.orders.includes(:reservations).where(:id => params[:id]).first

    @order.setup_transaction_for_checkout                                                                          # saves transaction, items, and payment
    
    @gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(                                                 # setup gateway, login to Paypal API
      :pem =>       PAYPAL_CONFIG[:paypal_cert_pem],
      :login =>     PAYPAL_CONFIG[:api_login],
      :password =>  PAYPAL_CONFIG[:api_password],
      :signature => PAYPAL_CONFIG[:api_signature],
      :appid =>     PAYPAL_CONFIG[:appid] )
    
    recipients = [ {:email        => @order.seller.account.paypal_username,                                               # setup recipients            
                    :payment_type => "GOODS",                                                                     # tell paypal this payment is for non-digital goods 
                    :invoice_id   => @order.transaction.transaction_number,
                    :primary      => true,                                                                             # seller is primary receiver
                    :amount       => @order.total_cost },                                                                # all the money goes through primary
                   {:email        => PAYPAL_CONFIG[:account_email],                                        
                    :payment_type => "SERVICE",                                                                   # second leg of the payment is for service
                    :primary      => false,                                                
                    :amount       => @order.transaction.payment.commission + @order.transaction.payment.shipping_cost  } ] # we get commission + shipping on back end
    
    encoded_secret = Base64.encode64(@order.transaction.payment.calculate_secret).encode('utf-8')               # encryptor uses ascii-8bit encoding, we need to convert to utf-8 to put in parameter... see http://stackoverflow.com/questions/11042657/how-to-encrypt-data-in-a-utf-8-string-using-opensslcipher

    if mobile_device?
      return_url = order_checkout_success_url(:format => :mobile, :secret => encoded_secret)
      cancel_url = order_checkout_failure_url(:format => :mobile)
    else
      return_url = order_checkout_success_url(:secret => encoded_secret)
      cancel_url = order_checkout_failure_url
    end

    @purchase = @gateway.setup_purchase(
      :action_type          => "CREATE",
      :return_url           => return_url, 
      :cancel_url           => cancel_url,
      :ipn_notification_url => payment_notification_url(:id => @order.transaction.id,                            # allows us to checkout the transaction using IPN
                                                        :secret => encoded_secret,                              # for security, so people can't approve transactions on the back-end without paying
                                                        :cart_id => current_cart.id),                           # so we can clear the cart from IPN in case user doesn't clear it on checkout_success_path (scenario where user closes browser or changes url before closing paypal light box)
      :memo                 => "Purchase of #{@order.item_count} item(s) from user #{@order.seller.username} on MTGBazaar.com.  Details of this order can be accessed at any time through your account on the MTGBazaar website.",
      :receiver_list        => recipients,
      :fees_payer           => "PRIMARYRECEIVER" )

    @gateway.set_payment_options(
      :display_options => { :business_name => "MTGBazaar" },
      :pay_key => @purchase["payKey"],
      :receiver_options => [
        {
          :invoice_data => {
            :item => [
              { :name => "Purchase of #{@order.item_count} Items",  :item_price => @order.item_price_total, :price => @order.item_price_total },
              { :name => "Shipping",                                 :item_price => @order.shipping_cost,    :price => @order.shipping_cost }
            ]
          },
          :receiver => { :email => @order.seller.account.paypal_username }
        },
        {
          :description => "MTGBazaar Fees and Shipping",
          :invoice_data => {
            :item => [
              { :name => "MTGBazaar Sale Commission", :item_price => @order.transaction.payment.commission,    :price => @order.transaction.payment.commission },
              { :name => "Shipping",                  :item_price => @order.shipping_cost,                     :price => @order.shipping_cost }
            ]
          },
          :receiver => { :email => PAYPAL_CONFIG[:account_email] }
        }
      ]
    )

    Rails.logger.debug "GATEWAY: #{@gateway.debug.inspect}"  rescue ""
    Rails.logger.debug "PURCHASE: #{@purchase.inspect}" rescue ""
    
    @order.transaction.payment.paypal_paykey            = @purchase["payKey"]
    @order.transaction.payment.paypal_purchase_response = @purchase.inspect 
    @order.transaction.payment.save!

    respond_to do |format|
      format.mobile do
        redirect_to @gateway.redirect_url_for(@purchase["payKey"])
      end
      format.js {}
    end
  end
  
  def verify_minimum_order_amount
    @order ||= current_cart.orders.includes(:reservations).where(:id => params[:id]).first    
    if @order.item_price_total < minimum_price_for_checkout
      flash[:error] = "Minimum order value $5.00 for checkout..."
      redirect_to back_path
      return
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
    respond_to do |format|
      format.html { render :layout => false }        # this will just load javascript that will reload the current page (show cart) to get rid of the light box
      format.mobile { redirect_to show_cart_path }
    end
  end
  
  def checkout_failure
    cookies[:checkout] = "failure"  # when show cart page is displayed it will have a failure message
    respond_to do |format|
      format.html { render :layout => false }        # this will just load javascript that will reload the current page (show cart) to get rid of the light box
      format.mobile { redirect_to show_cart_path }
    end

  end
  
end