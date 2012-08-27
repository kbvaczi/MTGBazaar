class AccountBalanceTransfersController < ApplicationController

  before_filter :authenticate_user!
  
  include ActionView::Helpers::NumberHelper  # needed for number_to_currency  
  
  def index
    set_back_path
    @transfers = current_user.account.balance_transfers.includes(:payment_notifications).order("account_balance_transfers.created_at DESC").page(params[:page]).per(13)
  end
  
  def test_payment
    
    test_withdraw = AccountBalanceTransfer.new(:balance => 10.50 )
    test_withdraw.account_id = current_user.id
    test_withdraw.transfer_type = "withdraw"
    test_withdraw.save
    
    ActiveMerchant::Billing::Base.mode = :test
    
    gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(
      :login => "seller_1345565383_biz_api1.mtgbazaar.com",
      :password => "QTJ6M8L94ETKL785",
      :signature => "An5ns1Kso7MWUdW4ErQKJJJ4qi4-AXsCplSrsdFPNjiVUhXnxPrq8Tl-",
      :appid => "APP-80W284485P519543T" )

    recipients = [ {:email => 'buyer_1344264179_per@mtgbazaar.com',
                    :invoice_id => test_withdraw.id,
                    :amount => test_withdraw.balance.dollars } ]

    purchase = gateway.setup_purchase(
      :action_type => "CREATE",
      :return_url => root_url,
      :cancel_url => root_url,
      :ipn_notification_url => create_withdraw_notification_url(:secret => "b4z44r2012!"),  
      :sender_email    => "seller_1345565383_biz@mtgbazaar.com",
      :memo => "Account Withdraw of $10.50",
      :receiver_list => recipients )

    gateway.execute_payment(purchase)

    respond_to do |format|
      format.html { render :text => gateway.debug }
    end
    
    return
    
  end
  
  def new_account_deposit
    set_back_path
    if params[:account_balance_transfer].present?
     @deposit = AccountBalanceTransfer.new(params[:account_balance_transfer]) 
    else
     @deposit = AccountBalanceTransfer.new
    end    
    session[:return_to] = request.referer
  end

  def create_account_deposit
    params[:account_balance_transfer][:current_password] = 0 if params[:account_balance_transfer][:current_password] == 1
    params[:account_balance_transfer][:current_password] = 1 if current_user.valid_password?(params[:account_balance_transfer][:current_password])
    @deposit = AccountBalanceTransfer.new(params[:account_balance_transfer])
    @deposit.transfer_type = "deposit"
    @deposit.current_sign_in_ip = request.remote_ip
    @deposit.account_id = current_user.account.id
    @deposit.approved_at = @deposit.created_at
    if @deposit.save
      redirect_to paypal_deposit_url(@deposit), :method => :post
      #current_user.account.balance_transfers << @deposit #link this deposit to current user's account
      #current_user.account.update_attribute(:balance, current_user.account.balance + @deposit.balance) #add deposit to user's balance
      #redirect_to session[:return_to] || :back, :notice => "Deposit Sucessful..."
    else
      flash[:error] = "There were one or more errors while trying to process your request"
      render 'new_account_deposit'
    end
  end

   def new_account_withdraw
     set_back_path
     if params[:account_balance_transfer].present?
       @withdraw = AccountBalanceTransfer.new(params[:account_balance_transfer]) 
     else
       @withdraw = AccountBalanceTransfer.new
     end    
   end

   def create_account_withdraw
     # hack to handle password check since the model validator doesn't have access to devise password check methods...
     params[:account_balance_transfer][:current_password] = 0 if params[:account_balance_transfer][:current_password] == 1
     params[:account_balance_transfer][:current_password] = 1 if current_user.valid_password?(params[:account_balance_transfer][:current_password])
     
     @withdraw = AccountBalanceTransfer.new(params[:account_balance_transfer])
     @withdraw.transfer_type = "withdraw"      
     @withdraw.current_sign_in_ip = request.remote_ip # log user's IP address     
     current_user.account.balance_transfers << @withdraw # link this withdraw to current user's account     
     if current_user.account.balance - @withdraw.balance < 0
       flash[:error] = "You have insufficient funds in your account"
       render 'new_account_withdraw'
       return
     elsif @withdraw.save
       # we are not deducting account funds until the withdraw is approved via admin panel
       # current_user.account.update_attribute(:balance, current_user.account.balance + @withdraw.balance) #subtract withdraw from account
       redirect_to back_path, :notice => "Your withdraw request will be processed shortly..."
     else
       flash[:error] = "There were one or more errors while trying to process your request"
       render 'new_account_withdraw'
     end
   end
   
# CONTROLLER METHODS ------------------------------------------------------------------------ #
  
  protected
   
  # generates a link to follow to paypal for deposits
  def paypal_deposit_url(deposit)
   values = {
     :business => "seller_1345565383_biz@mtgbazaar.com",
     :cmd => "_cart",
     :upload => 1,
     :return => acknowledge_deposit_url,
     :invoice => deposit.id,
     "amount_1" => paypal_commission(deposit.balance.dollars),
     "item_name_1" => "#{current_user.username}: #{number_to_currency(deposit.balance.dollars)} deposit",
     :notify_url => create_deposit_notification_url(:secret => "b4z44r2012!"),
     :cert_id => "6NXAAY8BWC9HQ"
   }
   params = {
     :cmd => "_s-xclick",
     :encrypted => encrypt_for_paypal(values)
   }
   "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end

  # computes paypal commission based on price in dollars
  def paypal_commission(base_price)
    # base paypal commission is 2.9% + 30 cents... we are adding .304 to handle rounding issues.  Paypal always rounds up.
    return ( base_price.to_f / ( 1 - 0.029 ) + 0.304 ).round(2)
  end
  
  # reads SSL certificates from file
  PAYPAL_CERT_PEM = File.read("#{Rails.root}/certs/paypal_cert.pem")
  APP_CERT_PEM = File.read("#{Rails.root}/certs/app_cert.pem")
  APP_KEY_PEM = File.read("#{Rails.root}/certs/app_key.pem")
  
  # encrypts values for sending deposits securely to paypal
  def encrypt_for_paypal(values)
      signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(APP_CERT_PEM), OpenSSL::PKey::RSA.new(APP_KEY_PEM, ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
      OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CERT_PEM)], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
  end
 
end
