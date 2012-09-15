class Mtg::Transactions::ShippingLabelsController < ApplicationController
  
  before_filter :authenticate_user! # must be logged in to make or edit listings
  before_filter :verify_owner # user has access to create and/or view this shipping label
    
  def create
    if current_transaction.shipping_label.present?
      #redirect_to current_transaction.shipping_label.url
      data = open(current_transaction.shipping_label.url)
      send_data data.read, :type => data.content_type, :x_sendfile=>true, :filename => "#{current_transaction.transaction_number} - Shipping Label.png"
    else
      label = Mtg::Transactions::ShippingLabel.new(:transaction => current_transaction)
      if label.save
        data = open(label.url)
        send_data data.read, :type => data.content_type, :x_sendfile=>true, :filename => "#{current_transaction.transaction_number} - Shipping Label.png"
      else
        flash[:error] = label.errors.full_messages
        redirect_to back_path
      end
    end
  end
  
  private 
  
  def verify_owner
    unless current_transaction.seller == current_user
      flash[:error] = "You don't have permission to perform this action..."
      redirect_to back_path
      return false
    end
  end
  
  def current_transaction
    @transaction ||= Mtg::Transaction.find(params[:id])
  end
  
end
