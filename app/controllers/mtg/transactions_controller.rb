class Mtg::TransactionsController < ApplicationController
  
  before_filter :set_back_path, :except => [:authenticate_user_or_token]
  before_filter :authenticate_user_or_token

  def seller_sale_confirmation
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    if not @transaction.present?
      flash[:error] = "There was a problem trying to process your request."
      redirect_to root_path
    elsif not @transaction.seller_confirmed? # this transaction hasn't been previously confirmed by seller
      @transaction.mark_as_seller_confirmed! # this transaction is now confirmed by seller
      @transaction.listings.each { |l| l.mark_as_sold! } # mark all listings for this transaction as sold
      ApplicationMailer.send_seller_shipping_information(@transaction).deliver # send sale notification email to seller
      ApplicationMailer.send_buyer_sale_confirmation(@transaction).deliver # notify buyer that the sale has been confirmed      
      redirect_to root_path, :notice => "Sale successfully confirmed! Shipping information will be delivered to you shortly."
    else # this sale has already been confirmed
      flash[:error] = "You have already confirmed this sale."
      redirect_to root_path
    end
  end
  
  def seller_sale_rejection
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_rejection_privileges?(@transaction) # this transaction exists, current user is seller, and transaction hasn't been previously confirmed or rejected already
  end
  
  def create_seller_sale_rejection
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    return if not verify_rejection_privileges?(@transaction) # this transaction exists, current user is seller, and transaction hasn't been previously confirmed or rejected already    
    if @transaction.update_attributes(:seller_rejected_at =>  Time.now, 
                                      :rejection_reason =>    params[:mtg_transaction][:rejection_reason],
                                      :rejection_message =>   params[:mtg_transaction][:rejection_message])
      ApplicationMailer.send_buyer_sale_rejection(@transaction).deliver # notify buyer that the sale has been confirmed
      @transaction.buyer.account.balance_credit!(@transaction.total_value) # credit buyer's account
      # need to send mail and credit buyer account prior to deleting transaction
      @transaction.remove_listings! # clear all the listings underneath this transaction so they can be purchased again        
      redirect_to root_path, :notice => "You rejected this sale..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'seller_sale_rejection'
    end
  end
    
  def buyer_delivery_confirmation
  
  end
  
  def buyer_sale_feedback
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    return if not verify_feedback_privileges?(@transaction)
  end
  
  def create_buyer_sale_feedback
    @transaction = Mtg::Transaction.where(:buyer_id => current_user.id, :id => params[:id]).first
    return if not verify_feedback_privileges?(@transaction) # this transaction hasn't been previously reviewed and is valid
    if @transaction.update_attributes(:seller_rating => params[:mtg_transaction][:seller_rating], 
                                      :seller_feedback => params[:mtg_transaction][:seller_feedback])
      redirect_to root_path, :notice => "Your feedback was sent..."
    else
      flash[:error] = "There were one or more errors while trying to process your request..."
      render 'buyer_sale_feedback'
    end
  end

  private 
  
  # in order to confirm transaction steps, user must sign in or send request with valid email token.
  # email tokens are not working yet.
  def authenticate_user_or_token
    authenticate_user!
  end
  
  def verify_rejection_privileges?(transaction)
    if not transaction.present? # user inputted invalid transaction_id
      flash[:error] = "There was a problem trying to process your request..."
      redirect_to root_path
      return false
    elsif transaction.seller_confirmed? # this transaction has already been confirmed
      flash[:error] = "You have already confirmed this sale. You cannot reject sale at this point in time..."
      redirect_to root_path
      return false
    elsif transaction.seller_rejected? # this transaction hasn't been previously confirmed by seller
      flash[:error] = "This sale was already rejected..."
      redirect_to root_path
      return false       
    end
    return true
  end
  
  def verify_feedback_privileges?(transaction)
    if not @transaction.present? # user inputted invalid transaction_id
      flash[:error] = "There was a problem trying to process your request..."
      redirect_to root_path
      return false
    elsif @transaction.buyer_reviewed? # this transaction has been previously reviewed
      flash[:error] = "You have already reviewed this transaction..."
      redirect_to root_path
      return false
    end
    return true
  end
  
end