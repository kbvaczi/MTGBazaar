class Mtg::TransactionsController < ApplicationController
  
  before_filter :authenticate_user!

  def seller_sale_confirmation
    create_back_path
    @transaction = Mtg::Transaction.where(:seller_id => current_user.id, :id => params[:id]).first
    if not @transaction.present?
      flash[:error] = "There was a problem trying to process your request."
      redirect_to root_path
    elsif @transaction.seller_confirmed_at.nil? # this transaction hasn't been previously confirmed by seller
      @transaction.update_attribute(:seller_confirmed_at, Time.now()) # this transaction is now confirmed by seller
      @transaction.listings.each { |l| l.update_attribute(:sold_at, Time.now()) } # mark all listings for this transaction as sold
      ApplicationMailer.send_seller_shipping_information(@transaction).deliver # send sale notification email to seller
      redirect_to root_path, :notice => "Sale successfully confirmed! Shipping information will be delivered to you shortly."
    else # this sale has already been confirmed
      flash[:error] = "You have already confirmed this sale."
      redirect_to root_path
    end
  end
  
  def seller_sale_rejection
    
  end
    
  def buyer_delivery_confirmation
  
  end
  
  # in order to confirm transaction steps, user must sign in or send request with valid email token.
  # email tokens are not working yet.
  def authenticate_user_or_token
    authenticate_user!
  end
  
  
end