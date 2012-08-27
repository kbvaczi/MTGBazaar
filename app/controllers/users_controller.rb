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
    @user = User.includes(:statistics, :account).find(params[:id])
    @listings = @user.mtg_listings.available.includes({:card => :set}).order("#{ params[:sort_by].present? ? params[:sort_by].to_s: "mtg_cards.name" } ASC").page(params[:page]).per(20) if params[:section] == "mtg_cards"
    @sales = @user.mtg_sales.where(:status => "delivered").order("created_at DESC").page(params[:page]).per(10) if params[:section] == "feedback"
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end
  
  def display_current_listings
    set_back_path
    @active_listings = current_user.mtg_listings.active.page(params[:page]).per(15)

    if params[:status] == "active"
      @listings = current_user.mtg_listings.includes(:card => :set).where(:active => true).order("mtg_cards.name ASC").page(params[:page]).per(25)
    elsif params[:status] == "inactive"
      @listings = current_user.mtg_listings.includes(:card => :set).where(:active => false).order("mtg_cards.name ASC").page(params[:page]).per(25)      
    else
      @listings = current_user.mtg_listings.includes(:card => :set).order("mtg_cards.name ASC").page(params[:page]).per(25)
    end
  end
  
  def account_info 
    set_back_path    
  end
  
  def show_cart
    set_back_path
    @reservations = current_cart.reservations.includes(:listing)
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
