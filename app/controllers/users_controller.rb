class UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :autocomplete_name, :autocomplete_name_chosen, :validate_username_ajax]
  
  include ApplicationHelper
  
  def index
    set_back_path
    users_sort_string = table_sort(:default => "LOWER(username)", :member_since => "created_at", :user => "LOWER(username)", :sales => "user_statistics.number_sales",
                                   :purchases => "user_statistics.number_purchases", :feedback => "user_statistics.approval_percent")    
    @users = User.includes(:statistics).active.order(users_sort_string).page(params[:page]).per(15)
  end
  
  # GET /users/1
  def show
    set_back_path    
    @user = User.includes(:statistics, :account).where('users.username LIKE ?', params[:id]).first || User.includes(:statistics, :account).find(params[:id])
    if params[:section] == "feedback"
      @sales = @user.mtg_sales.includes(:feedback).where("mtg_transactions_feedback.id > 0").order("mtg_transactions_feedback.created_at DESC").page(params[:page]).per(10) 
    elsif params[:section] == "mtg_cards"
      query = mtg_filters_query(:seller => false, :activate_filters => params[:filter])    
      listings_sort_string = table_sort(:default => "LOWER(mtg_cards.name)", :price => "price", :condition => "mtg_listings.condition", :language => "mtg_listings.language",
                                        :quantity => "mtg_listings.quantity", :name => "LOWER(mtg_cards.name)", :set => "mtg_sets.release_date")
      @listings = @user.mtg_listings.includes(:card => :set).where(query).available.order(listings_sort_string).page(params[:page]).per(15)
    end
    
    respond_to do |format|
      format.html # show.html.erb
    end
  end
  
  def account_info 
    set_back_path    
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
      @sales = current_user.mtg_sales.includes(:items).where(:status => params[:status]).order("created_at DESC").page(params[:page]).per(12)
    else
      @sales = current_user.mtg_sales.includes(:items).order("created_at DESC").page(params[:page]).per(12)
    end
  end
  
  def account_purchases
    set_back_path    
    if params[:status].present?
      @sales = current_user.mtg_purchases.includes(:items).where(:status => params[:status]).order("created_at DESC").page(params[:page]).per(12)
    else
      @sales = current_user.mtg_purchases.includes(:items).order("created_at DESC").page(params[:page]).per(12)
    end
  end  
  
  # autocomplete name handler for filtering cards by seller
  def autocomplete_name
    @users = User.where("username LIKE ?", "%#{params[:term]}%").active.limit(10).order("username ASC")
    respond_to do |format|
      format.json {}  #loads view autocomplete_name.json.erb which returns json hash array of information
    end
  end
  
  def autocomplete_name_chosen
    @users = User.select(["users.id", :username]).joins(:statistics).where("username LIKE ?", "#{params[:term]}%").active.limit(20).order("user_statistics.number_sales, username ASC")
    respond_to do |format|
      format.json do
=begin        
        return_hash = Hash.new
        if @users.present?
          @users.each do |u|
            computed_label = "#{u.username}"
            computed_value = "#{u.id}"
            return_hash.merge! Hash[ computed_value => computed_label ]
          end
        end
        render :json => return_hash
=end
        return_hash = Hash.new
        users_hash = Hash.new
        if @users.present?
          @users.each do |u|
            users_hash.merge! Hash[ "#{u.id}" => "#{u.username}" ]
          end
          return_hash.merge! Hash[ "Search Results" => {:name => "Search Results", :items => users_hash } ]
        end
        render :json => return_hash
        
      end
    end
  end
    
  def seller_status_toggle
    current_user.update_attribute(:active, !current_user.active)
    respond_to do |format|
      format.js {}
    end
  end
    
  def validate_username_ajax
    hypothetical_user = User.new(:username => params[:desired_username].downcase)
    hypothetical_user.valid?
    respond_to do |format|
      format.json {render :json => hypothetical_user.errors[:username].first.to_json}
    end
  end
    
end
