class HomeController < ApplicationController

  
  def index
   
    if user_signed_in?
      @news_feeds = NewsFeed.available_to_view.order("created_at DESC").limit(1) #.page(params[:page]).per(5)
    else
      @news_feeds = NewsFeed.where(:id => 1)
    end
    
    Rails.logger.info(GirlFriday.status)
    
  end
  
  def test
    

      # setup transaction
      gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(                                                 # setup gateway, login to Paypal API
        :pem =>       PAYPAL_CONFIG[:paypal_cert_pem],
        :login =>     PAYPAL_CONFIG[:api_login],
        :password =>  PAYPAL_CONFIG[:api_password],
        :signature => PAYPAL_CONFIG[:api_signature],
        :appid =>     PAYPAL_CONFIG[:appid] )

      recipients = [ {:email => "darnovo@gmail.com",
                      :primary => true,
                      :amount => "10.00" },
                      
                      {:email => "paypal@mtgbazaar.com",
                       :primary => false,
                       :amount => "2.00" } ]   
                       
      second_leg =   [ {:email => "seller_1348611401_per@mtgbazaar.com",
                        :primary => false,
                        :amount => "8.00" } ]
                         
      refunder     =  [ {:email => "seller_1345565383_biz@mtgbazaar.com",
                         :primary => true,
                         :amount => "5.00" } ]                         
=begin
       @pre_approval = gateway.preapprove_payment(
         :return_url            => root_url(:notice => "return"),
         :cancel_url            => root_url(:notice => "cancel"),
         :displayMaxTotalAmount => "TRUE", 
         :memo                  => "<br/>$52 dollars total split among 5 transactions. <br/>Note: Your account will be charged when seller confirms sale",
         :start_date            => Time.now,
         :end_date              => Time.now + 30.days,
        # :sender_email         => "buyer_1348611316_per@mtgbazaar.com",

         :currency_code        => "USD",
         :max_amount           => "50.00",
         :max_number_of_payments  => "5" )
=end

      @purchase = gateway.setup_purchase(
        :action_type          => "PAY",
        :return_url           => root_url(:notice => "return"),
        :cancel_url           => root_url(:notice => "cancel"),
        :memo                 => "TEST",
        :receiver_list        => recipients,
        :fees_payer           => "PRIMARYRECEIVER"
      )
  
 
=begin
      gateway.set_payment_options(
        :display_options => {
          :business_name    => "MTGBazaar",
          :header_image_url => "https://s3.amazonaws.com/mtgbazaar/images/mtg/logo/logo_sm.png"
        },
        :pay_key => purchase["payKey"],
        :receiver_options => [
          {
            :description => "XYZ Processing fee",
            :invoice_data => {
              :item => [{ :name => "SUPER ITEM", :item_count => 1, :item_price => 11, :price => 11 }]
            },
            :receiver => { :email => "seller_1345565383_biz@mtgbazaar.com" }
          }
        ]
      )
=end

      #Rails.cache.write "test_paykey", @purchase['payKey']





      # For redirecting the customer to the actual paypal site to finish the payment.
      #redirect_to (gateway.redirect_pre_approval_url_for(@pre_approval["preapprovalKey"]))
      
      # For redirecting the customer to the actual paypal site to finish the payment.
      #redirect_to (gateway.redirect_url_for(@purchase["payKey"]))
      #redirect_to (gateway.embedded_flow_url_for(@purchase["payKey"]))      
      
      #redirect_to "https://www.paypal.com/webapps/adaptivepayment/flow/pay?paykey=#{@purchase[:payKey]}"
 
      
                               
      # COMPLETE DELAYED PAYMENT
      #@response = gateway.execute_payment(:pay_key => Rails.cache.read("test_paykey"), :receiver_list => second_leg)                               
      #@refund = gateway.refund(:pay_key => Rails.cache.read("test_paykey"), :receiver_list        => second_leg )  

      Rails.logger.info "GATEWAY: #{gateway.debug.inspect}"  rescue ""
      Rails.logger.info "PREAPPROVAL: #{@pre_approval.inspect}"rescue ""
      Rails.logger.info "PURCHASE: #{@purchase.inspect}"rescue ""
      Rails.logger.info "PAYKEY: #{@purchase["PayKey"] rescue ""}"      
      Rails.logger.info "REFUND: #{@refund.inspect}" rescue ""  
      Rails.logger.info "RESPONSE: #{@response.inspect}" rescue ""
      Rails.logger.info "PERMISSION REQUEST: #{@permission_setup.inspect}" rescue ""      
      Rails.logger.info "TOKEN DATA: #{token_data.inspect}" rescue ""            
      Rails.logger.info "SCOPES: #{scopes.inspect}" rescue ""                  
    
    #render :nothing => true
    #return
  end
  
end
