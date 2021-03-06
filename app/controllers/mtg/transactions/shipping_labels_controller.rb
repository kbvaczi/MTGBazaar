class Mtg::Transactions::ShippingLabelsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in
  # right now either buyer or seller can track package
  before_filter :verify_buyer_or_seller, :only => [:track]  # user has access to create and/or view this shipping label
  before_filter :verify_seller, :only => [:create]  # user has access to create and/or view this shipping label  
    
  def create
    if current_transaction.shipping_label.present?
      @label = current_transaction.shipping_label
    elsif current_transaction.shipping_options[:shipping_type] == 'usps'
      begin
        @label = Mtg::Transactions::ShippingLabel.new(:transaction => current_transaction)
        if not @label.save
          Rails.logger.info("@label.errors.full_messages")
          flash[:error] = "There was a problem retreiving your shipping label.  Please try again later..."
          redirect_to back_path
          return
        end
        Rails.logger.info("STAMP CREATED")
        @error = false
      rescue Exception => message
        Rails.logger.info("STAMPS ERROR MESSAGE: #{message}")
        if message.to_s.include?("Invalid destination address")
          @error = "The ship-to address entered for this transaction appears to be invalid.  Please contact an administrator..."
        else
          @error = "There was a problem attempting to create your shipping label, please try again later.  If this problem persists, please contact an administrator"
        end
      end 
    else
      redirect_to back_path
    end
  
    respond_to do |format|
      format.html { redirect_to @label.params[:url] } 
      format.js  { current_transaction.reload }
    end
  end
  
  def track
    label = current_transaction.shipping_label
    if label.present?
      if label.updated_at < 3.hours.ago || label.tracking.nil? # tracking doesn't exists or hasn't been updated for awhile
        Rails.logger.info("Attempting to track transaction #{current_transaction.transaction_number}")
        if label.update_tracking
          @response = label.tracking
        else
          @error = "Cannot update tracking information at this time, please try again later..."
        end
      else # user has updated tracking recently... let's just show them what they saw last time
        @response = label.tracking 
      end
    else
      render :nothing => true
      return
    end

    respond_to do |format|
      format.js  { }
    end
  end

  private 
  
  def verify_seller
    unless current_transaction.seller == current_user
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to back_path
      return false
    end
  end
  
  def verify_buyer
    unless current_transaction.buyer == current_user
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to back_path
      return false
    end
  end
  
  def verify_buyer_or_seller
    unless current_transaction.seller == current_user || current_transaction.buyer == current_user
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to back_path
      return false
    end
  end
  
  def current_transaction
    @transaction ||= Mtg::Transaction.find(params[:id])
  end
  
end
