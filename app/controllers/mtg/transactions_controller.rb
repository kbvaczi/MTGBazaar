class Mtg::TransactionsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in to access any of these pages
  
  def show
    set_back_path
    @transaction = Mtg::Transaction.includes(:items => {:card => :set}).find(params[:id])
    if current_user.id != @transaction.buyer_id && current_user.id != @transaction.seller_id
      flash[:error] = "You do not have privileges to perform this action..."
      redirect_to back_path
    end
    @items = @transaction.items.includes(:card => :set).order("mtg_cards.name").page(params[:page]).per(16) if params[:section] == "items"
    if params[:section] == "communication"    
      @communications    = @transaction.communications.order("created_at DESC").page(params[:page]).per(5)
      @communications.unread.each {|c| c.update_attribute(:unread, false) if c.receiver_id == current_user.id}  # set messages to read so they no longer show up in communication center
      @new_communication = Communication.new(:mtg_transaction_id => @transaction.id)
    end
  end
  
##### ---------- SELLER SALE CONFIRMATION ------------- #####

  def seller_sale_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_seller_response_privileges?(@transaction) # this transaction exists, current user is seller, and transaction hasn't been previously confirmed or rejected already
  end

  def create_seller_sale_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    if not @transaction.present?
      flash[:error] = "There was a problem trying to process your request."
      redirect_to account_sales_path
    elsif not @transaction.seller_confirmed? # this transaction hasn't been previously confirmed by seller
      @transaction.confirm_sale # this transaction is now confirmed by seller
      #Mtg::Transactions::ShippingLabelQueue.push(:transaction => @transaction)      
      redirect_to account_sales_path, :notice => "Sale successfully confirmed! Shipping information will be delivered to you shortly."
    else # this sale has already been confirmed
      flash[:error] = "You have already confirmed this sale."
      redirect_to account_sales_path
    end
  end
  
##### ---------- SELLER SALE REJECTION ------------- #####
##### ---------- SELLER SALE REJECTION ------------- #####  
  
  def seller_sale_rejection
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_seller_response_privileges?(@transaction) # this transaction exists, current user is seller, and transaction hasn't been previously confirmed or rejected already
  end
  
  def create_seller_sale_rejection
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_seller_response_privileges?(@transaction) # this transaction exists, current user is seller, and transaction hasn't been previously confirmed or rejected already    
    if @transaction.reject_sale(params[:mtg_transaction][:rejection_reason], params[:mtg_transaction][:response_message])
      redirect_to account_sales_path, :notice => "Your sale was rejected."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'seller_sale_rejection'
    end
  end 

##### ------ SELLER SHIPMENT CONFIRMATION ----- #####    

  def seller_shipment_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_shipment_privileges?(@transaction)
  end

  def create_seller_shipment_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_shipment_privileges?(@transaction)    
    if @transaction.ship_sale
      ApplicationMailer.delay(:queue => :email).buyer_shipment_confirmation(@transaction) # notify buyer that the sale has been confirmed 
      redirect_to show_mtg_transaction_path(@transaction), :notice => "You have confirmed shipment of this sale..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'seller_shipment_confirmation'
    end
  end
  
##### ------ ORDER INVOICE PAGE ----- #####    

  def show_invoice
     @transaction = Mtg::Transaction.includes(:seller, :buyer, :items => {:card => :set}).find(params[:id])
     respond_to do |format|
       format.html { render :layout => false }
     end
  end
    
##### ------ SELLER PICKUP CONFIRMATION ----- #####

  def pickup_confirmation
    @transaction = Mtg::Transaction.where('seller_id = ? OR buyer_id = ?', current_user.id, current_user.id).where(:id => params[:id]).first
    if @transaction.present? and @transaction.shipping_options[:shipping_type] == 'pickup'
      @transaction.update_attributes(:seller_delivered_at => Time.now,
                                     :status              => 'delivered')
      redirect_to back_path, :notice => 'Pickup Confirmed...'                                     
    else
      flash[:error] = 'you do not have permission to perform this action...'
      redirect_to back_path
    end
  end
    
##### ------ BUYER DELIVERY CONFIRMATION ----- #####    

  def buyer_delivery_confirmation
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
  end
  
  def create_buyer_delivery_confirmation
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    if @transaction.deliver_sale(params[:mtg_transaction][:buyer_feedback], params[:mtg_transaction][:buyer_feedback_text])
      redirect_to account_purchases_path, :notice => "Your delivery confirmation was sent..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'buyer_delivery_confirmation'
    end    
  end  

##### ------ BUYER SALE FEEDBACK ----- #####    
  
  def buyer_sale_feedback
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    return if not verify_feedback_privileges?(@transaction)
  end
  
  def create_buyer_sale_feedback
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    return if not verify_feedback_privileges?(@transaction) # this transaction hasn't been previously reviewed and is valid
    if @transaction.update_attributes(:seller_rating => params[:mtg_transaction][:seller_rating], 
                                      :buyer_feedback => params[:mtg_transaction][:buyer_feedback])
      redirect_to account_purchases_path, :notice => "Your feedback was sent..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'buyer_sale_feedback'
    end
  end

##### ------ PRIVATE CLASS METHODS ----- #####    

  private 
  
  def verify_seller_response_privileges?(transaction)
    if not transaction.present? # user inputted invalid transaction_id
      flash[:error] = "There was a problem trying to process your request..."
      redirect_to account_sales_path
      return false
    elsif transaction.seller_confirmed? # this transaction has already been confirmed
      flash[:error] = "You have already confirmed this sale..."
      redirect_to account_sales_path
      return false
    elsif transaction.seller_rejected? # this transaction hasn't been previously confirmed by seller
      flash[:error] = "This sale was already rejected..."
      redirect_to account_sales_path
      return false       
    end
    return true
  end
  
  def verify_feedback_privileges?(transaction)
    if not @transaction.present? # user inputted invalid transaction_id
      flash[:error] = "There was a problem trying to process your request..."
      redirect_to back_path
      return false
    elsif @transaction.buyer_reviewed? # this transaction has been previously reviewed
      flash[:error] = "You have already reviewed this transaction..."
      redirect_to back_path
      return false
    end
    return true
  end
  
  def verify_shipment_privileges?(transaction)
    if not transaction.present? # user inputted invalid transaction_id or transction cannot be shipped at its current stage
      flash[:error] = "There was a problem trying to process your request..."
      redirect_to back_path
      return false
    elsif transaction.seller_shipped_at != nil # this transaction has already been shipped
      flash[:error] = "You have already confirmed shipment of this sale..."
      redirect_to back_path
      return false
    end
    return true
  end
  
  def verify_buyer_review_privileges?(transaction)
    if not transaction.present? # user inputted invalid transaction_id
      flash[:error] = "There was a problem trying to process your request..."
      redirect_to back_path
      return false
    end
    if not transaction.seller_confirmed_at.present? or transaction.buyer_confirmed_at.present?
      flash[:error] = "you cannot modify this sale at this time"
      redirect_to back_path
      return false
    end
    return true
  end
  
  def verify_update_quantity?(item)
    if params["quantity_available_#{item.id}"].to_i < 0 
      flash[:error] = "you cannot have negative item(s) available"
      return false
    end
    if params["quantity_available_#{item.id}"].to_i > item.quantity_requested
      flash[:error] = "you cannot make the buyer take more cards than originally requested"
      return false
    end
    return true
  end
  
end