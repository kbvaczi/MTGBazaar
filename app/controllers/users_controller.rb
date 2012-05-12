class UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:new, :create, :show, :autocomplete_name]
  
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
    set_back_path    
    @user = User.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end
  
  def display_current_listings
    set_back_path
    @active_listings = current_user.mtg_listings.active
    @inactive_listings = current_user.mtg_listings.inactive    
  end
  
  def account_info 
    set_back_path    
  end
  
  def show_cart
    set_back_path
    @reservations = current_cart.reservations.includes(:listing)
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
  
  def transactions_index
  end
  
  def account_sales
    set_back_path
    if params[:status].present?
      @sales = current_user.mtg_sales.where(:status => params[:status]).order("created_at DESC").page(params[:page]).per(15)
    else
      @sales = current_user.mtg_sales.order("created_at DESC").page(params[:page]).per(15)
    end
  end
  
  def account_purchases
    set_back_path    
    if params[:status].present?
      @sales = current_user.mtg_purchases.where(:status => params[:status]).order("created_at DESC").page(params[:page]).per(15)
    else
      @sales = current_user.mtg_purchases.order("created_at DESC").page(params[:page]).per(15)
    end
  end  
  
  # autocomplete name handler for filtering cards by seller
  def autocomplete_name
    @users = User.where("username LIKE ?", "%#{params[:term]}%").limit(15).where(:banned => false).sort {|x,y| x[:username] <=> y[:username] } # give me 15 users then filter by banned ones (no index on banned column)
    respond_to do |format|
      format.json {}  #loads view autocomplete_name.json.erb which returns json hash array of information
    end
  end
    
end
