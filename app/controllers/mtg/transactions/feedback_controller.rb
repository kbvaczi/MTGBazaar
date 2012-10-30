class Mtg::Transactions::FeedbackController < ApplicationController  

  before_filter :verify_buyer,            :only => [:new, :create]  
  before_filter :verify_feedback_absent,  :only => [:new, :create]  
  
  before_filter :verify_seller,           :only => [:new_response, :create_response]
  before_filter :verify_feedback_present, :only => [:new_response, :create_response]
  
  def new
    @feedback ||= current_transaction.build_feedback(params[:mtg_transactions_feedback])
  end
  
  def create
    @feedback = current_transaction.build_feedback(params[:mtg_transactions_feedback])
    if @feedback.save
      current_transaction.update_attribute(:status, "completed")
      current_transaction.seller.statistics.update_seller_statistics!
      redirect_to show_mtg_transaction_path(current_transaction), :notice => "Your feedback was created..."
    else
      flash[:error] = "There was an error with your request..."
      render 'new'
    end
    
    return # don't display a view
  end
  
  def new_response
    @feedback ||= current_transaction.feedback
  end
  
  def create_response
    @feedback ||= current_transaction.feedback
    @feedback.seller_response_comment = params[:mtg_transactions_feedback][:seller_response_comment]
    if @feedback.save
      redirect_to show_mtg_transaction_path(current_transaction), :notice => "Your feedback response was created..."
    else
      flash[:error] = "There was an error with your request..."
      render 'new_response'
    end
    
    return # don't display a view
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
  
  def verify_feedback_present
    unless current_transaction.feedback.present?
      flash[:error] = "You cannot leave a response to feedback that doesn't exist..."
      redirect_to back_path
      return false
    end
  end

  def verify_feedback_absent
    if current_transaction.feedback.present?
      flash[:error] = "Feedback already exists for this transaction..."
      redirect_to back_path
      return false
    end
  end  
  
  def current_transaction
    @transaction ||= Mtg::Transaction.find(params[:id])
  end
  
end