class Mtg::Transactions::ShippingLabelsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in to make or edit listings
  # right now either buyer or seller can track package
  # before_filter :verify_buyer, :only => [:track]  # user has access to create and/or view this shipping label
  before_filter :verify_seller, :only => [:create]  # user has access to create and/or view this shipping label  
    
  def create
    if current_transaction.shipping_label.present?
      @label = current_transaction.shipping_label
    else
      begin
        @label = Mtg::Transactions::ShippingLabel.new(:transaction => current_transaction)
        if not @label.save 
          Rails.logger.info("@label.errors.full_messages")
          flash[:error] = "There was a problem retreiving your shipping label.  Please try again later..."
          redirect_to back_path
          return
        end
        Rails.logger.debug("STAMP CREATED")
      rescue Exception => message
        Rails.logger.debug("STAMPS ERROR MESSAGE: #{message}")
        @error = true
      end 
    end
    
    respond_to do |format|
      format.html do 
        redirect_to @label.params[:url]
      end
      format.js  { }
    end
  end
  
  def track
    label = current_transaction.shipping_label
    if label.present?
      if label.updated_at < 3.hours.ago || label.tracking.nil? # tracking doesn't exists or hasn't been updated for awhile
        Rails.logger.info("Attempting to track transaction #{current_transaction.transaction_number}")
        begin
          @response = Stamps.track(current_transaction.shipping_label.stamps_tx_id)
          label.update_attribute(:tracking, @response)
        rescue Exception => message
          if message.to_s.include?('The underlying connection was closed') # error you get when there is no info
            @error = "No tracking information at this time..."
          else
            @error = "Cannot connect to tracking service at this time..."
          end
          Rails.logger.info("Error Tracking #{current_transaction.transaction_number}: #{message}")
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
  
  def current_transaction
    @transaction ||= Mtg::Transaction.find(params[:id])
  end
  
end
