class AccountBalanceTransfersController < ApplicationController

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
    @deposit.current_sign_in_ip = request.remote_ip
    @deposit.account_id = current_user.account.id
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
     session[:return_to] = request.referer
   end

   def create_account_withdraw
     params[:account_balance_transfer][:current_password] = 0 if params[:account_balance_transfer][:current_password] == 1
     params[:account_balance_transfer][:current_password] = 1 if current_user.valid_password?(params[:account_balance_transfer][:current_password])
     @withdraw = AccountBalanceTransfer.new(params[:account_balance_transfer])
     if current_user.account.balance - @withdraw.balance < 0
       flash[:error] = "Insufficient funds"
       render 'new_account_withdraw'
       return
     end
     if @withdraw.save
       @withdraw.update_attribute(:current_sign_in_ip, request.remote_ip) #log depositor's IP address
       @withdraw.update_attribute(:balance, "#{@withdraw.balance * -1}") #change the balance from a credit to a debit
       current_user.account.balance_transfers << @withdraw #link this withdraw to current user's account
       current_user.account.update_attribute(:balance, current_user.account.balance + @withdraw.balance) #subtract withdraw from account
       redirect_to session[:return_to] || :back, :notice => "Withdraw Sucessful..."
     else
       flash[:error] = "There were one or more errors while trying to process your request"
       render 'new_account_withdraw'
     end
   end
   
   # CONTROLLER METHODS
   protected
   
   def paypal_deposit_url(deposit)
     params = {
       :business => "seller_1344264004_biz@mtgbazaar.com",
       :cmd => "_cart",
       :upload => 1,
       :return => root_url,
       :invoice => deposit.id,
       "amount_1" => paypal_commission(deposit.balance.dollars),
       "item_name_1" => "#{deposit.balance.dollars} deposit to MTGBazaar",
       :notify_url => payment_notifications_url
     }

     "https://www.sandbox.paypal.com/cgi-bin/webscr?" + params.to_query
   end

   # computes paypal commission based on price in dollars
   def paypal_commission(base_price)
     # base paypal commission is 2.9% + 30 cents
     return (base_price + base_price.to_f * 0.029 + 0.30).round(2)
   end
   
end
