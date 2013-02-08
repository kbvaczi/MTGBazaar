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
  
  def account_seller_panel
    set_back_path
    respond_to do |format|
      format.html do 
        if params[:section] == 'listings'
          render :template => 'account/account_listings'          
        else
          render :template => 'account/seller_panel'
        end
      end
      format.js do
        if params[:section] == 'overview'          
          default_js_render :template => 'account/seller_panel'
        else
          default_js_render :template => 'account/account_listings'
        end
      end 
    end
  end
  
  def listings_price_analysis
    set_back_path    
    @listings = current_user.mtg_listings.includes(:card => [:set, :statistics]).where(:id => params[:listing_ids]).order("mtg_cards.name ASC").page(params[:page]).per(20)    
    respond_to do |format|
      format.html do 
        render :template => 'account/listings_price_analysis'
      end
      format.js do
        default_js_render :template => 'account/listings_price_analysis'
      end
      format.overlay do
        overlay_js_render :template => 'account/listings_price_analysis'
      end 
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
