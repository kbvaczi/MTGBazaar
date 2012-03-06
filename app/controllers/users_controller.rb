class UsersController < ApplicationController

  autocomplete :user, :username
  before_filter :authenticate_user!, :except => [:new, :create]

  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end
  
  def display_current_listings 
  end
  
  def account_info 
  end
  
  def new_account_deposit
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
    if @deposit.save
      @deposit.update_attribute(:current_sign_in_ip, request.remote_ip) #log depositor's IP address
      current_user.account.balance_transfers << @deposit #link this deposit to current user's account
      current_user.account.update_attribute(:balance, current_user.account.balance + @deposit.balance) #add deposit to user's balance
      redirect_to session[:return_to] || :back, :notice => "Deposit Sucessful..."
    else
      flash[:error] = "There were one or more errors while trying to process your request"
      render 'new_account_deposit'
    end
  end

  def new_account_withdraw
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
    
end
