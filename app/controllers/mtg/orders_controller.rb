class Mtg::OrdersController < ApplicationController
  
  before_filter :verify_minimum_order_amount, :only => [:checkout]
  
  def checkout
    @order ||= current_cart.orders.includes(:reservations).where(:id => params[:id]).first

    @order.setup_transaction_for_checkout                                                                          # saves transaction, items, and payment
    @purchase_chained_payment = @order.transaction.payment.commission + @order.transaction.payment.shipping_cost > 0.to_money ? true : false
    
    checkout_setup_purchase
    checkout_set_purchase_options
    
    @order.transaction.payment.paypal_paykey            = @purchase["payKey"]
    @order.transaction.payment.paypal_purchase_response = @purchase.inspect 
    @order.transaction.payment.save!

    respond_to do |format|
      format.mobile { redirect_to "#{@gateway.embedded_flow_url}?paykey=#{@purchase['payKey']}" } 
      format.html   { redirect_to "#{@gateway.embedded_flow_url}?paykey=#{@purchase['payKey']}" }       
      format.js     {}
    end
  end
  
  def checkout_setup_purchase
    @gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(                                                 # setup gateway, login to Paypal API
      :pem =>       PAYPAL_CONFIG[:paypal_cert_pem],
      :login =>     PAYPAL_CONFIG[:api_login],
      :password =>  PAYPAL_CONFIG[:api_password],
      :signature => PAYPAL_CONFIG[:api_signature],
      :appid =>     PAYPAL_CONFIG[:appid] )
    
    if @purchase_chained_payment
      recipients = [ {:email        => @order.seller.account.paypal_username,                                               # setup recipients            
                      :payment_type => "GOODS",                                                                     # tell paypal this payment is for non-digital goods 
                      :invoice_id   => @order.transaction.transaction_number,
                      :primary      => true,                                                                             # seller is primary receiver
                      :amount       => @order.total_cost },                                                                # all the money goes through primary
                     {:email        => PAYPAL_CONFIG[:account_email],                                        
                      :payment_type => "SERVICE",                                                                   # second leg of the payment is for service
                      :primary      => false,                                                
                      :amount       => @order.transaction.payment.commission + @order.transaction.payment.shipping_cost  } ] # we get commission + shipping on back end
    else 
      recipients = [ {:email        => @order.seller.account.paypal_username,                                               # setup recipients            
                      :payment_type => "GOODS",                                                                     # tell paypal this payment is for non-digital goods 
                      :invoice_id   => @order.transaction.transaction_number,
                      :amount       => @order.total_cost } ]                                                                # all the money goes through primary
    end
    
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
      :ipn_notification_url => payment_notification_url(:id       => @order.transaction.id,                            # allows us to checkout the transaction using IPN
                                                        :secret   => encoded_secret,                              # for security, so people can't approve transactions on the back-end without paying
                                                        :cart_id  => current_cart.id),                           # so we can clear the cart from IPN in case user doesn't clear it on checkout_success_path (scenario where user closes browser or changes url before closing paypal light box)
      :memo                 => "Purchase of #{@order.item_count} item(s) for a total of #{@order.reservations.pluck(:cards_quantity).inject(0) {|sum, count| sum + count }} cards from #{@order.seller.username} on MTGBazaar.com.  Details of this order can be accessed at any time through your account on the MTGBazaar website. #{'NOTE: By selecting In-Store Pickup, you accept the responsibility of aquiring these purchase items yourself.  In-Store Pickup is not recommended unless you are familiar with the retailer you are purchasing from.' if @order.shipping_options[:shipping_type] == 'pickup'}",
      :receiver_list        => recipients,
      :fees_payer           => @purchase_chained_payment ? "PRIMARYRECEIVER" : "EACHRECEIVER" )
      
      Rails.logger.debug "GATEWAY: #{@gateway.debug}"  rescue ""
      Rails.logger.debug "PURCHASE: #{@purchase.inspect}" rescue ""    
  end

  def checkout_set_purchase_options
    items_first_leg  = [{ :name => "Purchase of #{@order.item_count} Item(s)", :item_price => @order.item_price_total,               :price => @order.item_price_total }]
    items_second_leg = [{ :name => "Sale Commission",                          :item_price => @order.transaction.payment.commission, :price => @order.transaction.payment.commission }]
    if @order.shipping_options[:shipping_type] == 'usps'
      common_items     =  [{ :name => 'Shipping',               :item_price => @order.shipping_options[:shipping_charges][:basic_shipping] ,        :price => @order.shipping_options[:shipping_charges][:basic_shipping]}]
      common_items     <<  { :name => 'Shipping Insurance',     :item_price => @order.shipping_options[:shipping_charges][:insurance],              :price => @order.shipping_options[:shipping_charges][:insurance] }              if @order.shipping_options[:shipping_charges][:insurance].present?
      common_items     <<  { :name => 'Signature Confirmation', :item_price => @order.shipping_options[:shipping_charges][:signature_confirmation], :price => @order.shipping_options[:shipping_charges][:signature_confirmation] } if @order.shipping_options[:shipping_charges][:signature_confirmation].present?      
      items_first_leg  += common_items
      items_second_leg += common_items
    else
      items_first_leg << { :name => 'In-Store Pickup', :item_price => 0, :price => 0 }
    end
    options_hash = {:display_options => { :business_name => "MTGBazaar" },
                    :pay_key => @purchase["payKey"],
                    # force buyer to select an address or enter an address when they make a payment.
                    :sender => @order.shipping_options[:shipping_type] == 'usps' ? { :share_address => true, :require_shipping_address_selection => true } : {},
                    :receiver_options => [
                      { :invoice_data => {
                          :item => items_first_leg
                        },
                        :receiver => { :email => @order.seller.account.paypal_username }
                      },
                      { :description => "MTGBazaar Fees and Shipping",
                        :invoice_data => {
                          :item => items_second_leg
                        },
                        :receiver => { :email => PAYPAL_CONFIG[:account_email] }
                      }] }
    options_hash[:receiver_options] = [options_hash[:receiver_options][0]] unless @purchase_chained_payment
    @gateway.set_payment_options(options_hash)    
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
      format.html   { render :layout => false }        # this will just load javascript that will reload the current page (show cart) to get rid of the light box
      format.mobile { redirect_to show_cart_path }
    end
  end
  
  def checkout_failure
    cookies[:checkout] = "failure"  # when show cart page is displayed it will have a failure message
    respond_to do |format|
      format.html   { render :layout => false }        # this will just load javascript that will reload the current page (show cart) to get rid of the light box
      format.mobile { redirect_to show_cart_path }
    end

  end
  
  def update_shipping_options
    @order            = current_cart.orders.where(:id => params[:id]).first
    new_shipping_type = params[:shipping_type] == 'pickup' && @order.seller.ship_option_pickup_available? ? 'pickup' : 'usps'
    @shipping_params  = Mtg::Transactions::ShippingLabel.calculate_shipping_parameters( :card_count    => @order.cards_quantity, 
                                                                                        :item_value    => @order.item_price_total,
                                                                                        :insurance     => params[:shipping_option_insurance] == 'true' && new_shipping_type == 'usps',
                                                                                        :signature     => params[:shipping_option_signature] == 'true' && new_shipping_type == 'usps',
                                                                                        :shipping_type => new_shipping_type )
    new_insurance_cost              = @shipping_params[:shipping_options_charges][:insurance]
    new_signature_confirmation_cost = @shipping_params[:shipping_options_charges][:signature_confirmation]
    new_shipping_cost               = @shipping_params[:shipping_options_charges][:basic_shipping]
    
    shipping_charges                          = {:basic_shipping => new_shipping_cost}
    shipping_charges[:signature_confirmation] = new_signature_confirmation_cost if new_signature_confirmation_cost
    shipping_charges[:insurance]              = new_insurance_cost if new_insurance_cost
    
    @order.shipping_options         = {:shipping_type    => new_shipping_type,
                                       :shipping_charges => shipping_charges }
    @order.shipping_cost            = @shipping_params[:total_shipping_charge]
    @order.total_cost               = @order.item_price_total + @order.shipping_cost
    @order.save!
    
    respond_to do |format|
      format.js
    end
  end
end