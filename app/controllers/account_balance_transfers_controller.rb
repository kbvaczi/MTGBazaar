class AccountBalanceTransfersController < ApplicationController

  before_filter :authenticate_user!
  
  include ActionView::Helpers::NumberHelper  # needed for number_to_currency  
  
  def index
    set_back_path
    @transfers = current_user.account.balance_transfers.includes(:payment_notifications).order("account_balance_transfers.created_at DESC").page(params[:page]).per(13)
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
    @deposit.approved_at = Time.now # deposits are always approved
    if @deposit.save
      redirect_to paypal_deposit_url(@deposit), :method => :post
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
     @withdraw.account_id = current_user.account.id  # link this withdraw to current user's account             
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
    :business => PAYPAL_CONFIG[:account_email], # business account info on paypal
    :cmd => "_xclick", #acts as a "buy now" button
    :return => acknowledge_deposit_url, # user is returned here after successful purchase
    :cancel_return => cancel_deposit_url(:invoice => deposit.id), # user cancels deposit prior to paying
    :rm => 1, #return using GET method
    :invoice => deposit.id, #invoice passthrough variable
    :amount => paypal_commission(deposit.balance.dollars), #amount to pay
    :item_name => "#{current_user.username}: #{number_to_currency(deposit.balance.dollars)} deposit", 
    :cert_id => PAYPAL_CONFIG[:cert_id], # encryption certificate ID on paypal's site
    :notify_url => create_deposit_notification_url(:secret => PAYPAL_CONFIG[:secret]) # where to send payment notification    
  }
   params = {
     :cmd => "_s-xclick",
     :encrypted => encrypt_for_paypal(values)
   }
   PAYPAL_CONFIG[:paypal_url] + params.to_query
  end

  # computes total price including paypal commission based on price in dollars
  def paypal_commission(base_price)
    # base paypal commission is 2.9% + 30 cents... we are adding .304 to handle rounding issues.  Paypal always rounds up.
    return ( ( base_price.to_f / ( 1 - 0.029 ) ) + 0.304 ).round(2)
  end
  
  # encrypts values for sending deposits securely to paypal
  def encrypt_for_paypal(values)
      signed = OpenSSL::PKCS7::sign(OpenSSL::X509::Certificate.new(PAYPAL_CONFIG[:app_cert_pem]), OpenSSL::PKey::RSA.new(PAYPAL_CONFIG[:app_key_pem], ''), values.map { |k, v| "#{k}=#{v}" }.join("\n"), [], OpenSSL::PKCS7::BINARY)
      OpenSSL::PKCS7::encrypt([OpenSSL::X509::Certificate.new(PAYPAL_CONFIG[:paypal_cert_pem])], signed.to_der, OpenSSL::Cipher::Cipher::new("DES3"), OpenSSL::PKCS7::BINARY).to_s.gsub("\n", "")
  end
 
end
