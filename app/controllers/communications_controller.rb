class CommunicationsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :verify_eligible_transaction, :only => [:create]
  
  def index
    set_back_path
    if params[:section] == "recent"  # recent messages (1 month ago or newer)
      @communications = current_user.communications_received.includes(:sender, :transaction).where("created_at > \'#{1.month.ago}\'").order("created_at DESC").page(params[:page]).per(12)
    else 
      @communications = current_user.communications_received.includes(:sender, :transaction).where(:unread => true).order("unread ASC, created_at DESC").page(params[:page]).per(12)      
    end
  end
  
  def show
    set_back_path
    @communication = current_user.communications_received.includes(:sender, :transaction).where(:id => params[:id]).first
    @communication.update_attribute(:unread, false) if @communication.unread?
  end
  
  def create
    @communication = Communication.new(params[:communication])
    @communication.sender      = current_user # can't set ID directly due to polymorphic model... need ID and type...
    @communication.receiver_id = current_user.id == @transaction.buyer.id ? @transaction.seller.id : @transaction.buyer.id
    unless @communication.save
      flash[:error] = "There was a problem with your request"
      redirect_to show_mtg_transaction_path(@transaction, {:section => "communication", :message => @communication.message})
      return
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