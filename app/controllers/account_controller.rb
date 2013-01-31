class AccountController < ApplicationController

  before_filter :authenticate_user!
  
  include ApplicationHelper
  
  def account_info 
    set_back_path 
    respond_to do |format|
      format.html
      format.js  { default_js_render :template => 'account/account_info' }
    end       
  end
  
  def account_listings
    set_back_path
    query = mtg_filters_query(:seller => false, :activate_filters => params[:filter])    
    if params[:status] == "inactive"
      if params[:type] == "playsets"
        @listings = current_user.mtg_listings.includes(:card => :set).where(query).where(:playset => true).inactive.order("mtg_cards.name ASC").page(params[:page]).per(50)
      else
        @listings = current_user.mtg_listings.includes(:card => :set).where(query).where(:playset => false).inactive.order("mtg_cards.name ASC").page(params[:page]).per(50)
      end
    else
      if params[:type] == "playsets"
        @listings = current_user.mtg_listings.includes(:card => :set).where(query).where(:playset => true).active.order("mtg_cards.name ASC").page(params[:page]).per(50)
      else
        @listings = current_user.mtg_listings.includes(:card => :set).where(query).where(:playset => false).active.order("mtg_cards.name ASC").page(params[:page]).per(50)
      end      
    end
    
    respond_to do |format|
      format.html
      format.js  { default_js_render :template => 'account/account_listings' }
    end
  end
  
  def account_sales
    set_back_path
    if params[:status].present?
      @sales = current_user.confirmed_sales.includes(:items).where(:status => params[:status]).order("created_at DESC").page(params[:page]).per(14)
    else
      @sales = current_user.confirmed_sales.includes(:items).order("created_at DESC").page(params[:page]).per(14)
    end
    respond_to do |format|
      format.html
      format.js  { default_js_render :template => 'account/account_sales' }
    end
  end
  
  def account_purchases
    set_back_path    
    if params[:status].present?
      @sales = current_user.confirmed_purchases.includes(:items).where(:status => params[:status]).order("created_at DESC").page(params[:page]).per(14)
    else
      @sales = current_user.confirmed_purchases.includes(:items).order("created_at DESC").page(params[:page]).per(14)
    end
    respond_to do |format|
      format.html
      format.js  { default_js_render :template => 'account/account_purchases' }
    end
  end  
    
  def seller_status_toggle
    current_user.active = !current_user.active
    current_user.save
    respond_to do |format|
      format.js {}
    end
  end

end
