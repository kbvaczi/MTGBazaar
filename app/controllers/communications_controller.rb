class CommunicationsController < ApplicationController
  
  before_filter :verify_eligible_transaction
  
  def create
    @communication = Communication.new(params[:communication])
    @communication.sender_id   = current_user.id
    @communication.receiver_id = current_user.id == @transaction.buyer.id ? @transaction.seller.id : @transaction.buyer.id
    unless @communication.save
      flash[:error] = "There was a problem with your request"
      redirect_to back_path(params)
    end
    
    redirect_to back_path, :notice => "Message Sent"
  end
  
  def verify_eligible_transaction
    @transaction ||= Mtg::Transaction.find(params[:communication][:mtg_transaction_id])
    if @transaction.buyer.id != current_user.id && @transaction.seller.id != current_user.id
      flash[:error] = "You do not have privileges to perform this action... #{@transaction.inspect}"
      redirect_to back_path
    end
    if @transaction.created_at < 30.days.ago || @transaction.feedback.present?
      flash[:error] = "Communication for this transaction has been closed..."
      redirect_to back_path
    end
  end
  
  
end