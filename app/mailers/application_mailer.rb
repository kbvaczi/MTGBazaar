class ApplicationMailer < ActionMailer::Base
  
  helper "mtg::cards"
  
  default :from => "\"MTGBazaar Notifications\" <noreply@mtgbazaar.com>"

  def account_update_notification(user)
    @user = user
    mail(:to => user.email, :subject => "MTGBazaar Account Information Change")
  end

  def buyer_checkout_confirmation(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Purchase request: #{@transaction.transaction_number}" ) 
  end

  def seller_sale_notification(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.seller    
    mail(:to => @recipient.email, :subject => "Pending sale: #{@transaction.transaction_number}" ) 
  end

  def seller_shipping_information(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.seller
    mail(:to => @recipient.email, :subject => "Shipping information: #{@transaction.transaction_number}" ) 
  end

  def seller_cancellation_notice(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.seller
    mail(:to => @recipient.email, :subject => "Cancellation Notice: #{@transaction.transaction_number}" ) 
  end  

  def buyer_sale_confirmation(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Purchase confirmation: #{@transaction.transaction_number}" ) 
  end

  def buyer_shipment_confirmation(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Shipment confirmation: #{@transaction.transaction_number}" ) 
  end  
  
  def buyer_sale_rejection(transaction) #recipient is a User object, transaction is an Mtg::Transaction object
    @transaction = transaction
    @recipient = transaction.buyer
    mail(:to => @recipient.email, :subject => "Purchase rejection #{@transaction.transaction_number}" ) 
  end  

end