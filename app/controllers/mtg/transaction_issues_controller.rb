class Mtg::TransactionIssuesController < ApplicationController
# ------- CONTROLLER SETUP -------- #

  before_filter :authenticate_user! # must be logged in to access any of these pages
  before_filter :verify_authorship_privileges
  
# ------- VIEWS  -------- #    

  def new
    @issue = Mtg::Transaction.find(params[:id]).issues.build(params[:mtg_transaction_issue])
    respond_to do |format|
      format.html # only respond to html requests    
    end
  end
  
  def create
    transaction = Mtg::Transaction.find(params[:id])
    @issue = transaction.issues.build(params[:mtg_transaction_issue])
    @issue.author_id = current_user.id
    # verify user is in this transaction... if not throw an error
    if @issue.save
      redirect_to back_path, :notice => "problem report created..."
    else
      flash[:error] = "There was a problem with your request..."
      render 'new'
    end
  end
  
  def show
    
  end

# ------- CONTROLLER METHODS -------- #    
  
  def verify_authorship_privileges
    @transaction = Mtg::Transaction.find(params[:id])
    @issue = @transaction.issues.build(params[:mtg_transaction_issue])   
    @issue.author_id = current_user.id     
    if @issue.author_id != @transaction.buyer_id and @issue.author_id != @transaction.seller_id
      flash[:error] = "You are not invovlved with this transaction..."
      redirect_to back_path
    end
  end
  
end