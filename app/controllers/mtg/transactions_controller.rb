class Mtg::TransactionsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in to access any of these pages
  
  def show
    set_back_path
    @transaction = Mtg::Transaction.includes(:items => {:card => :set}).find(params[:id])
    @items = @transaction.items.includes(:card => :set).order("mtg_cards.name").page(params[:page]).per(16)
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
      ApplicationMailer.seller_shipping_information(@transaction).deliver # send sale notification email to seller
      ApplicationMailer.buyer_sale_confirmation(@transaction).deliver # notify buyer that the sale has been confirmed      
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
      ApplicationMailer.buyer_sale_rejection(@transaction).deliver # notify buyer that the sale has been confirmed
      redirect_to account_sales_path, :notice => "Your sale was rejected."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'seller_sale_rejection'
    end
  end
  
##### ---------- SELLER SALE MODIFICATION ------------- #####
##### ---------- SELLER SALE MODIFICATION ------------- #####  

  def seller_sale_modification
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_seller_response_privileges?(@transaction) # this transaction exists, current user is seller, and transaction hasn't been previously confirmed or rejected already
  end

  def create_seller_sale_modification
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_seller_response_privileges?(@transaction) # this transaction exists, current user is seller, and transaction hasn't been previously confirmed or rejected already    
    quantity_updated = false # have any quantities been updated?
    @transaction.items.each do |item|
      if params["quantity_available_#{item.id}"].present? && params["quantity_available_#{item.id}"].to_i != item.quantity_available #seller has changed this quantity
        if not verify_update_quantity?(item)
          render "seller_sale_modification"
          return
        end
        item.update_attributes(:quantity_available => params["quantity_available_#{item.id}"].to_i)   # update quantity available
        quantity_updated = true # quantities have been updated
      end
    end
    if quantity_updated # have quantities been updated? 
      #TODO: notify buyer by email that their purchase has been modified
      @transaction.update_attributes(:buyer_confirmed_at => nil, :seller_confirmed_at => Time.now, :response_message => params[:response_message] )  # seller has confirmed sale as modified, buyer must now reconfirm sale        
      redirect_to account_sales_path, :notice => "Your sale was modified. Buyer must now accept changes."      
    else
      flash[:error] = "You did not make any modifications"
      redirect_to back_path
    end
    return
  end  

##### ---------- BUYER SALE MODIFICATION REVEIW ------------- #####
##### ---------- BUYER SALE MODIFICATION REVIEW ------------- #####

  def buyer_sale_modification_review
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    @items = @transaction.items.includes(:card).order("mtg_cards.name ASC")
    @items_modified = @items.where("quantity_available <> quantity_requested")
    return if not verify_buyer_review_privileges?(@transaction) 
  end
  
  def create_buyer_sale_modification_review
    @transaction = Mtg::Transaction.includes(:items).where(:buyer_id => current_user.id, :id => params[:id]).first
    return if not verify_buyer_review_privileges?(@transaction)
    if params[:commit] == "Reject Changes"
      if @transaction.cancel_sale("modification") # mark status on transaction as cancelled and set cancellation reason
        ApplicationMailer.seller_cancellation_notice(@transaction).deliver # notify seller their transaction was cancelled
        flash[:notice] = "You rejected the buyer's modifications.  Sale #{@transaction.transaction_number} was cancelled."            
      else
        flash[:error] = "There were one or more errors while trying to process your request..."
      end
      redirect_to back_path
    elsif params[:commit] == "Accept Changes"
      @transaction.mark_as_buyer_confirmed_with_modifications!
      redirect_to back_path, :notice => "You accepted the buyer's modifications"      
    end
    return
  end
    
##### ---------- BUYER SALE CANCELLATION ------------- #####
##### ---------- BUYER SALE CANCELLATION ------------- #####
    
  def buyer_sale_cancellation
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    if not @transaction.present? 
      flash[:error] = "You do not have permission to perform this action"
      redirect_to back_path
    end
  end
  
  def create_buyer_sale_cancellation
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    return false if not buyer_sale_cancellation_validations
    if @transaction.cancel_sale(params[:mtg_transaction][:cancellation_reason]) # mark status on transaction as cancelled and set cancellation reason
      ApplicationMailer.seller_cancellation_notice(@transaction).deliver # notify seller their transaction was cancelled
      redirect_to account_purchases_path, :notice => "You cancelled this sale..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'buyer_sale_cancellation'
    end
  end
  
  def buyer_sale_cancellation_validations
    days_to_cancel = MTGBazaar::Application::DAYS_UNTIL_BUYER_CAN_CANCEL_UNCONFIRMED_ORDER
    if (params[:mtg_transaction].present? and params[:mtg_transaction][:cancellation_reason] == "confirmation") and (@transaction.status == "pending")
      if (@transaction.created_at < days_to_cancel.days.ago)
        return true # validation passes
      else
        flash[:error] = "You must wait #{days_to_cancel} days after order creation to perform this action"
        redirect_to back_path
        return false # validation fails
      end
    elsif not @transaction.present? 
      flash[:error] = "You do not have permission to perform this action"
      redirect_to back_path
      return false # validation fails
    else
      flash[:error] = "There was a problem with your request"
      redirect_to back_path
      return false # validation fails
    end
  end
      
##### ------ SELLER SHIPMENT CONFIRMATION ----- #####    
##### ------ SELLER SHIPMENT CONFIRMATION ----- #####    

  def seller_shipment_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_shipment_privileges?(@transaction)
  end
  #TODO: Add a way for buyer to track shipments
  def create_seller_shipment_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_shipment_privileges?(@transaction)    
    if @transaction.ship_sale
      ApplicationMailer.buyer_shipment_confirmation(@transaction).deliver # notify buyer that the sale has been confirmed 
      redirect_to account_sales_path, :notice => "You have confirmed shipment of this sale..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'seller_shipment_confirmation'
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
    if (not transaction.present?) or (transaction.status != "confirmed") # user inputted invalid transaction_id or transction cannot be shipped at its current stage
      flash[:error] = "There was a problem trying to process your request..."
      redirect_to back_path
      return false
    elsif transaction.status == "shipped" # this transaction has already been shipped
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