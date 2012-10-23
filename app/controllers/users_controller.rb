class UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :new, :create, :show, :autocomplete_name]
  
  include ApplicationHelper
  
  def index
    users_sort_string = table_sort(:default => "username", :member_since => "created_at", :user => "username", :sales => "user_statistics.number_sales",
                                   :purchases => "user_statistics.number_purchases", :feedback => "user_statistics.positive_feedback_count + user_statistics.neutral_feedback_count / user_statistics.number_sales")
    
    
    @users = User.includes(:statistics).active.order(users_sort_string).page(params[:page]).per(15)
    
    
    
  end
  
  # GET /users/1
  def show
    set_back_path    
    @user = User.includes(:statistics, :account).find(params[:id])
    @sales = @user.mtg_sales.includes(:items => {:card => :set}).where(:status => "delivered").order("created_at DESC").page(params[:page]).per(10) if params[:section] == "feedback"
    
    listings_sort_string = table_sort(:default => "mtg_cards.name", :price => "price", :condition => "mtg_listings.condition", :language => "mtg_listings.language",
                                      :quantity => "mtg_listings.quantity", :name => "mtg_cards.name", :set => "mtg_sets.release_date")
    
    @listings = @user.mtg_listings.includes(:card => :set).available.order(listings_sort_string).page(params[:page]).per(20) if params[:section] == "mtg_cards"
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  

  
  def account_info 
    set_back_path    
  end
  
 
  def transactions_index
  end
  
  def account_listings
    set_back_path
    query = SmartTuple.new(" AND ")
    query << ["mtg_sets.code  LIKE ?", "#{params[:filters][:set] }"] if params[:filters] && params[:filters][:set].present?
    query << ["mtg_cards.name LIKE ?", "#{params[:filters][:name]}"] if params[:filters] && params[:filters][:name].present?   

    if params[:status] == "active"
      @listings = current_user.mtg_listings.includes(:card => :set).where(query.compile).active.order("mtg_cards.name ASC").page(params[:page]).per(25)
    elsif params[:status] == "inactive"
      @listings = current_user.mtg_listings.includes(:card => :set).where(query.compile).inactive.order("mtg_cards.name ASC").page(params[:page]).per(25)      
    else
      @listings = current_user.mtg_listings.includes(:card => :set).where(query.compile).order("mtg_cards.name ASC").page(params[:page]).per(25)
    end
  end
  
  def account_sales
    set_back_path
    if params[:status].present?
      @sales = current_user.mtg_sales.where(:status => params[:status]).order("created_at DESC").page(params[:page]).per(12)
    else
      @sales = current_user.mtg_sales.order("created_at DESC").page(params[:page]).per(12)
    end
  end
  
  def account_purchases
    set_back_path    
    if params[:status].present?
      @sales = current_user.mtg_purchases.where(:status => params[:status]).order("created_at DESC").page(params[:page]).per(12)
    else
      @sales = current_user.mtg_purchases.order("created_at DESC").page(params[:page]).per(12)
    end
  end  
  
  # autocomplete name handler for filtering cards by seller
  def autocomplete_name
    @users = User.where("username LIKE ?", "%#{params[:term]}%").active.limit(10).order("username ASC") # give me 15 users then filter by banned ones (no index on banned column)
    respond_to do |format|
      format.json {}  #loads view autocomplete_name.json.erb which returns json hash array of information
    end
  end
    
  def seller_status_toggle
    current_user.update_attribute(:active, !current_user.active)
    respond_to do |format|
      format.js {}
    end
  end
    
end
