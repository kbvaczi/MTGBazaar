class Mtg::TransactionsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in to access any of these pages

  def seller_sale_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    if not @transaction.present?
      flash[:error] = "There was a problem trying to process your request."
      redirect_to back_path
    elsif not @transaction.seller_confirmed? # this transaction hasn't been previously confirmed by seller
      @transaction.mark_as_seller_confirmed! # this transaction is now confirmed by seller
      ApplicationMailer.send_seller_shipping_information(@transaction).deliver # send sale notification email to seller
      ApplicationMailer.send_buyer_sale_confirmation(@transaction).deliver # notify buyer that the sale has been confirmed      
      redirect_to back_path, :notice => "Sale successfully confirmed! Shipping information will be delivered to you shortly."
    else # this sale has already been confirmed
      flash[:error] = "You have already confirmed this sale."
      redirect_to back_path
    end
  end
  
  def seller_sale_rejection
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_rejection_privileges?(@transaction) # this transaction exists, current user is seller, and transaction hasn't been previously confirmed or rejected already
  end
  
  def create_seller_sale_rejection
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_rejection_privileges?(@transaction) # this transaction exists, current user is seller, and transaction hasn't been previously confirmed or rejected already    
    if @transaction.mark_as_seller_rejected!(params[:mtg_transaction][:rejection_reason], params[:mtg_transaction][:rejection_message])
      ApplicationMailer.send_buyer_sale_rejection(@transaction).deliver # notify buyer that the sale has been confirmed
      @transaction.buyer.account.balance_credit!(@transaction.total_value) # credit buyer's account
      @transaction.reject_listings! # clear all the listings underneath this transaction so they can be purchased again        
      redirect_to back_path, :notice => "You rejected this sale..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'seller_sale_rejection'
    end
  end
    
  def seller_shipment_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_shipment_privileges?(@transaction)
  end
  
  def create_seller_shipment_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_shipment_privileges?(@transaction)    
    if @transaction.mark_as_seller_shipped!(params[:mtg_transaction][:seller_tracking_number])
      ApplicationMailer.send_buyer_shipment_confirmation(@transaction).deliver # notify buyer that the sale has been confirmed 
      redirect_to back_path, :notice => "You have confirmed shipment of this sale..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'seller_shipment_confirmation'
    end
  end    
    
  def buyer_delivery_confirmation
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
  end
  
  def create_buyer_delivery_confirmation
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    if @transaction.update_attributes(:seller_rating => params[:mtg_transaction][:seller_rating], 
                                      :buyer_feedback => params[:mtg_transaction][:buyer_feedback],
                                      :seller_delivered_at => Time.now,
                                      :buyer_delivery_confirmation => params[:mtg_transaction][:buyer_delivery_confirmation],
                                      :status => "delivered")
      current_user.account.balance_credit!(@transaction.total_value)  # credit sellers account
      redirect_to back_path, :notice => "Your delivery confirmation was sent..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'buyer_delivery_confirmation'
    end    
  end  
  
  def buyer_sale_feedback
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    return if not verify_feedback_privileges?(@transaction)
  end
  
  def create_buyer_sale_feedback
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    return if not verify_feedback_privileges?(@transaction) # this transaction hasn't been previously reviewed and is valid
    if @transaction.update_attributes(:seller_rating => params[:mtg_transaction][:seller_rating], 
                                      :buyer_feedback => params[:mtg_transaction][:buyer_feedback])
      redirect_to back_path, :notice => "Your feedback was sent..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'buyer_sale_feedback'
    end
  end

  private 
  
  def verify_rejection_privileges?(transaction)
    if not transaction.present? # user inputted invalid transaction_id
      flash[:error] = "There was a problem trying to process your request..."
      redirect_to back_path
      return false
    elsif transaction.seller_confirmed? # this transaction has already been confirmed
      flash[:error] = "You have already confirmed this sale. You cannot reject sale at this point in time..."
      redirect_to back_path
      return false
    elsif transaction.seller_rejected? # this transaction hasn't been previously confirmed by seller
      flash[:error] = "This sale was already rejected..."
      redirect_to back_path
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
  
end