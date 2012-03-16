class Mtg::TransactionsController < ApplicationController
  
  def create
    
    @transaction = Mtg:Transaction.new
    @transaction.buyer = current_user
    if @transaction.save
      redirect_to back_path, :notice => "Cards Purchased, you should receive confirmation from the seller(s) soon."
    else
      flash[:error] = "There were one or more errors while trying to process your request"
      redirect_to back_path
    end
    
  end
  
  
  
end